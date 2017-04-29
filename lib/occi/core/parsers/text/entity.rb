module Occi
  module Core
    module Parsers
      module Text
        # Static parsing class responsible for extracting entities from plain text.
        # Class supports 'text/plain' via `plain`. No other formats are supported.
        #
        # @attr model [Occi::Core::Model, Occi::Infrastructure::Model] model to use as a primary reference point
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Entity
          include Yell::Loggable
          include Helpers::ArgumentValidator
          include Helpers::ErrorHandler

          # Regexp constants
          ATTRIBUTE_REGEXP = /#{Constants::REGEXP_ATTRIBUTE}/
          LINK_REGEXP      = /#{Constants::REGEXP_LINK}/

          # Typecasting lambdas
          DEFAULT_LAMBDA  = ->(val) { raise "#{self} -> Cannot typecast #{val.inspect} to an unknown type" }

          FLOAT_LAMBDA    = ->(val) { val.to_f }
          JSON_LAMBDA     = ->(val) { JSON.parse(val) }

          TYPECASTER_HASH = {
            IPAddr  => ->(val) { IPAddr.new val },
            URI     => ->(val) { URI.parse val },
            String  => ->(val) { val },
            Float   => FLOAT_LAMBDA,
            Numeric => FLOAT_LAMBDA,
            Integer => ->(val) { val.to_i },
            Boolean => ->(val) { val.casecmp('true') || val.casecmp('yes') },
            Array   => JSON_LAMBDA,
            Hash    => JSON_LAMBDA
          }.freeze

          attr_reader :model

          # Constructs an instance of the entity parser. Only entities (their kinds) defined by the model are allowed.
          #
          # @param args [Hash] constructor arguments in a Hash
          # @option args [Occi::Core::Model] :model model to use as a primary reference point
          def initialize(args = {})
            pre_initialize(args)
            default_args! args

            @model = args.fetch(:model)

            post_initialize(args)
          end

          # Builds an entity instances from the lines provided as input.
          #
          # @param lines [Array] list of lines containing a single entity rendering
          # @return [Occi::Core::Entity] constructed instance
          def plain(lines)
            cats = plain_categories(lines)
            kind = cats.detect { |c| c.is_a?(Occi::Core::Kind) }
            raise Occi::Core::Errors::ParsingError, "#{self.class} -> Entity does not specify its kind" unless kind

            entity = @_ib.build(kind.identifier)
            cats.each { |cat| cat.is_a?(Occi::Core::Mixin) && entity << cat }

            plain_attributes! lines, entity.attributes
            plain_links! lines, entity

            entity
          end

          # Parses categories from entity lines. Every category is looked up in the model.
          #
          # @param lines [Array] list of lines containing a single entity rendering
          # @return [Array] list of identified category instances
          def plain_categories(lines)
            lines.map do |line|
              next unless line.start_with?(TextParser::CATEGORY_KEYS.first)
              cat = Category.plain_category(line, false)
              handle(Occi::Core::Errors::ParsingError) { model.find_by_identifier!("#{cat[:scheme]}#{cat[:term]}") }
            end.compact
          end

          # Parses attributes from entity lines. Every attribute value is typed according to the attribute
          # specification provided by the model (in the defined kind).
          #
          # @param lines [Array] list of lines containing a single entity rendering
          # @param attributes [Hash] defined attributes
          # @return [Hash] parsed and typed attributes
          def plain_attributes!(lines, attributes)
            lines.each do |line|
              next unless line.start_with?(TextParser::ATTRIBUTE_KEYS.first)
              name, value = raw_attribute(line)
              unless attributes[name]
                raise Occi::Core::Errors::ParsingError,
                      "#{self.class} -> attribute #{name.inspect} is not allowed for this entity"
              end
              attributes[name].value = handle(Occi::Core::Errors::ParsingError) do
                typecast value, attributes[name].attribute_definition.type
              end
            end
            attributes
          end

          # Parses a single attribute line to identify name and value.
          #
          # @param line [String] line containing a single entity attribute
          # @return [Array] two-element array with name and value of the attribute
          def raw_attribute(line)
            matched = line.match(ATTRIBUTE_REGEXP)
            unless matched
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> #{line.inspect} does not match expectations for Attribute"
            end
            [matched[:name], matched[:string] || matched[:number] || matched[:bool]]
          end

          # Parses links attached to the entity instance. This includes both action "links" and ordinary
          # OCCI links between resources.
          #
          # @param lines [Array] list of lines containing a single entity rendering
          # @param entity [Occi::Core::Entity] partially constructed entity instance to be updated
          # @return [Occi::Core::Entity] updated entity instance
          def plain_links!(lines, entity)
            lines.each do |line|
              next unless line.start_with?(TextParser::LINK_KEYS.first)
              matched = line.match(LINK_REGEXP)
              unless matched
                raise Occi::Core::Errors::ParsingError,
                      "#{self.class} -> #{line.inspect} does not match expectations for Link"
              end
              plain_link! matched, entity
            end
            entity
          end

          # Constructs a single link instance. This includes both action "links" and ordinary OCCI links.
          #
          # @param md [MatchData] Hash-like structure with matched parts of the link
          # @param entity [Occi::Core::Entity] partially constructed entity instance to be updated
          def plain_link!(md, entity)
            md[:uri].include?('?action=') ? plain_action!(md, entity) : plain_oglink!(md, entity)
          end

          # Looks up the action mentioned in the given action "link" and assigns it to the given partially
          # constructed entity instance.
          #
          # @param md [MatchData] Hash-like structure with matched parts of the link
          # @param entity [Occi::Core::Entity] partially constructed entity instance to be updated
          def plain_action!(md, entity)
            entity << model.find_by_identifier!(md[:rel])
          end

          # Constructs a single link instance. Supports only ordinary OCCI links between resources.
          #
          # @param md [MatchData] Hash-like structure with matched parts of the link
          # @param entity [Occi::Core::Entity] partially constructed entity instance to be updated
          def plain_oglink!(md, entity)
            unless entity.respond_to?(:links)
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> Cannot assign links to entity #{entity.id} which does not support them"
            end

            link = plain_oglink_instance(md)
            link.location = URI.parse md[:self]
            entity.links << link

            plain_oglink_attributes! md, link

            entity
          end

          # Constructs a single link instance based on the provided data. The returned instance does include contain
          # action instance attributes!
          #
          # @param md [MatchData] Hash-like structure with matched parts of the link
          # @return [Occi::Core::Link] constructed link instance
          def plain_oglink_instance(md)
            if md[:category].blank? || md[:self].blank?
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> Link #{md[:uri].inspect} is missing type and location information"
            end

            categories = md[:category].split
            link = @_ib.build(categories.shift, rel: md[:rel])
            categories.each { |mxn| link << model.find_by_identifier!(mxn) }

            link
          end

          # Attaches attributes to an existing link instance.
          #
          # @param md [MatchData] Hash-like structure with matched parts of the link
          # @param link [Occi::Core::Link] partially constructed link instance to be updated
          def plain_oglink_attributes!(md, link)
            if md[:attributes].blank?
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> Link #{link.id} is missing attribute information"
            end

            line = md[:attributes].strip.gsub(/^;\s*/, '')
            attrs = line.split(';').map { |attrb| "#{TextParser::ATTRIBUTE_KEYS.first}: #{attrb}" }
            plain_attributes! attrs, link.attributes

            link
          end

          # Typecasts attribute values from String to the desired type.
          #
          # @param value [String] attribute value
          # @param type [Class,Module] desired attribute type
          # @return [Object] typecasted value
          def typecast(value, type)
            if value.nil? || type.nil?
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> Cannot typecast (un)set value to (un)set type"
            end

            self.class.typecaster[type].call(value)
          end

          class << self
            # Constructs a map pointing from expected attribute types to conversion lambdas.
            #
            # @return [Hash] typecaster hash with conversion lambdas
            def typecaster
              Hash.new(DEFAULT_LAMBDA).merge(TYPECASTER_HASH)
            end
          end

          protected

          # :nodoc:
          def sufficient_args!(args)
            return if args[:model]
            raise Occi::Core::Errors::MandatoryArgumentError, "Model is a mandatory argument for #{self.class}"
          end

          # :nodoc:
          def defaults
            { model: nil }
          end

          # :nodoc:
          def pre_initialize(args); end

          # :nodoc:
          def post_initialize(_args)
            @_ib = model.instance_builder
          end
        end
      end
    end
  end
end
