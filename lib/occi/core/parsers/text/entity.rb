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

          # Names of attributes requiring additional conversion
          RESOURCE_ATTRIBUTE_NAMES = %w[occi.core.source occi.core.target].freeze

          # Typecasting lambdas
          RESOURCE_LAMBDA = lambda do |val, model|
            model.instance_builder.build(
              Occi::Core::Constants::RESOURCE_KIND,
              id: val.split('/').last, location: URI.parse(val), title: 'Generated resource'
            )
          end
          CATEGORY_LAMBDA = ->(val, model) { model.find_by_identifier! val }
          IPADDR_LAMBDA   = ->(val, _) { IPAddr.new val }
          URI_LAMBDA      = ->(val, _) { URI.parse val }
          FLOAT_LAMBDA    = ->(val, _) { val.to_f }
          INTEGER_LAMBDA  = ->(val, _) { val.to_i }
          BOOLEAN_LAMBDA  = ->(val, _) { val.casecmp('true') || val.casecmp('yes') }
          STRING_LAMBDA   = ->(val, _) { val }
          DEFAULT_LAMBDA  = ->(val, _) { raise "#{self} -> Cannot typecast #{val.inspect} to an unknown type" }

          attr_reader :model

          # TODO: docs
          #
          # @param args [Hash]
          def initialize(args = {})
            pre_initialize(args)
            default_args! args

            @model = args.fetch(:model)

            post_initialize(args)
          end

          # TODO: docs
          #
          # @param lines [Array]
          # @return [Occi::Core::Entity]
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

          # TODO: docs
          #
          # @param lines [Array]
          # @return [Array]
          def plain_categories(lines)
            lines.map do |line|
              next unless line.start_with?(TextParser::CATEGORY_KEYS.first)
              cat = Category.plain_category(line, false)
              handle(Occi::Core::Errors::ParsingError) { model.find_by_identifier!("#{cat[:scheme]}#{cat[:term]}") }
            end.compact
          end

          # TODO: docs
          #
          # @param lines [Array]
          # @param attributes [Hash]
          # @return [Hash]
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

          # TODO: docs
          #
          # @param line [String]
          # @return [Array]
          def raw_attribute(line)
            matched = line.match(ATTRIBUTE_REGEXP)
            unless matched
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> #{line.inspect} does not match expectations for Attribute"
            end
            [matched[:name], matched[:string] || matched[:number] || matched[:bool]]
          end

          # TODO: docs
          #
          # @param lines [Array]
          # @param entity [Occi::Core::Entity]
          # @return [Occi::Core::Entity]
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

          # TODO: docs
          #
          # @param md [MatchData]
          # @param entity [Occi::Core::Entity]
          def plain_link!(md, entity)
            md[:uri].include?('?action=') ? plain_action!(md, entity) : plain_oglink!(md, entity)
          end

          # TODO: docs
          #
          # @param md [MatchData]
          # @param entity [Occi::Core::Entity]
          def plain_action!(md, entity)
            entity << model.find_by_identifier!(md[:rel])
          end

          # TODO: docs
          #
          # @param md [MatchData]
          # @param entity [Occi::Core::Entity]
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

          # TODO: docs
          #
          # @param md [MatchData]
          def plain_oglink_instance(md)
            if md[:category].blank? || md[:self].blank?
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> Link #{md[:uri].inspect} is missing type and location information"
            end

            categories = md[:category].split
            link = @_ib.build(categories.shift)
            categories.each { |mxn| link << model.find_by_identifier!(mxn) }

            link
          end

          # TODO: docs
          #
          # @param md [MatchData]
          # @param link [Occi::Core::Link]
          def plain_oglink_attributes!(md, link)
            if md[:attributes].blank?
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> Link #{link.id} is missing attribute information"
            end

            line = md[:attributes].strip.gsub(/^;\s*/, '')
            attrs = line.split(';').map { |attrb| "#{TextParser::ATTRIBUTE_KEYS.first}: #{attrb}" }
            plain_attributes! attrs, link.attributes
            plain_oglink_st! md, link

            link
          end

          # TODO: docs
          #
          # @param md [MatchData]
          # @param link [Occi::Core::Link]
          def plain_oglink_st!(md, link)
            RESOURCE_ATTRIBUTE_NAMES.each do |attrb|
              unless link[attrb]
                raise Occi::Core::Errors::ParsingError,
                      "#{self.class} -> Link #{link.id} is missing attribute #{attrb.inspect}"
              end

              link[attrb] = @_ib.build(
                md[:rel],
                id: link[attrb].id, location: link[attrb].location, title: link[attrb].title
              )
            end

            link
          end

          # TODO: docs
          #
          # @param value [String]
          # @param type [Class,Module]
          # @return [Object]
          def typecast(value, type)
            if value.nil? || type.nil?
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> Cannot typecast (un)set value to (un)set type"
            end

            self.class.typecaster[type].call(value, model)
          end

          class << self
            # Constructs a map pointing from expected attribute types to conversion lambdas.
            #
            # @return [Hash] typecaster hash with conversion lambdas
            def typecaster
              typecaster_hash = Hash.new(DEFAULT_LAMBDA)
              typecaster_hash[Occi::Core::Resource] = RESOURCE_LAMBDA
              typecaster_hash[Occi::Core::Category] = CATEGORY_LAMBDA
              typecaster_hash[IPAddr] = IPADDR_LAMBDA
              typecaster_hash[URI] = URI_LAMBDA
              typecaster_hash[String] = STRING_LAMBDA
              typecaster_hash[Float] = FLOAT_LAMBDA
              typecaster_hash[Numeric] = FLOAT_LAMBDA
              typecaster_hash[Integer] = INTEGER_LAMBDA
              typecaster_hash[Boolean] = BOOLEAN_LAMBDA
              typecaster_hash
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
