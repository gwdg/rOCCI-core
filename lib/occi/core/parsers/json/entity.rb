module Occi
  module Core
    module Parsers
      module Json
        # Static parsing class responsible for extracting entities from JSON.
        # Class supports 'application/json' via `json`. No other formats are supported.
        #
        # @attr model [Occi::Core::Model, Occi::Infrastructure::Model] model to use as a primary reference point
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Entity
          include Yell::Loggable
          include Helpers::ArgumentValidator
          include Helpers::ErrorHandler
          extend Helpers::RawJsonParser

          # Constants
          SINGLE_INSTANCE_TYPES = %i[resource link].freeze
          MULTI_INSTANCE_TYPES  = %i[entity-collection].freeze

          TYPECASTER_HASH = {
            IPAddr  => ->(val) { IPAddr.new val },
            URI     => ->(val) { URI.parse val },
            Float   => ->(val) { val.to_f },
            Integer => ->(val) { val.to_i }
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
          # @param body [String] JSON body for parsing
          # @param type [Symbol] `:resource`, `:link`, or `:'entity-collection'`
          # @return [Array] constructed instances
          def json(body, type)
            case type
            when *SINGLE_INSTANCE_TYPES
              json_single self.class.raw_hash(body)
            when *MULTI_INSTANCE_TYPES
              json_collection self.class.raw_hash(body)
            else
              raise Occi::Core::Errors::ParserError, "#{self.class} -> #{type.to_s.inspect} is not a valid type"
            end
          end

          # Builds an entity instance from the hash provided as input.
          #
          # @param hash [Hash] Hash body for parsing
          # @return [Array] constructed instances
          def json_single(hash)
            instance = @_ib.get hash[:kind], mixins: lookup(hash[:mixins]), actions: lookup(hash[:actions])

            set_attributes! instance.attributes, hash[:attributes]
            set_links! instance.links, hash[:links]
            fix_target! instance, hash[:target] if instance.respond_to?(:target)

            Set.new [instance]
          end

          # Builds entity instances from the hash provided as input.
          #
          # @param hash [Hash] Hash body for parsing
          # @return [Array] constructed instances
          def json_collection(hash)
            all = []

            all.concat hash[:resources] if hash[:resources]
            all.concat hash[:links] if hash[:links]
            all.map! { |a| json_single(a) }

            Set.new(all).flatten
          end

          # :nodoc:
          def lookup(ary)
            set = Set.new
            return set if ary.blank?
            ary.each { |i| set << handle(Occi::Core::Errors::ParsingError) { model.find_by_identifier!(i) } }
            set
          end

          # :nodoc:
          def set_attributes!(attributes, hash)
            return if hash.blank?
            hash.each_pair do |name, value|
              attribute = attributes[name.to_s]
              unless attribute
                raise Occi::Core::Errors::ParsingError,
                      "#{self.class} -> attribute #{name.to_s.inspect} is not allowed for this entity"
              end
              attribute.value = typecast(value, attribute.attribute_definition.type)
            end
          end

          def set_links!(links, ary)
            return if ary.blank?
            ary.each { |l| links << json_single(l) }
          end

          # :nodoc:
          def fix_target!(link, hash)
            return unless link.respond_to?(:target_kind)
            return if hash.blank? || hash[:kind].blank?

            link.target_kind = lookup([hash[:kind]]).first
          end

          # :nodoc:
          def typecast(value, type)
            if value.nil? || type.nil?
              raise Occi::Core::Errors::ParsingError,
                    "#{self.class} -> Cannot typecast (un)set value to (un)set type"
            end
            return value unless TYPECASTER_HASH.key?(type)

            TYPECASTER_HASH[type].call(value)
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
