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

          # Shortcuts to interesting methods on logger
          DELEGATED = %i[debug? info? warn? error? fatal?].freeze
          delegate(*DELEGATED, to: :logger, prefix: true)

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
            symbol = case type
                     when *SINGLE_INSTANCE_TYPES
                       :json_single
                     when *MULTI_INSTANCE_TYPES
                       :json_collection
                     else
                       raise Occi::Core::Errors::ParserError, "#{type.inspect} is not a valid type"
                     end

            send symbol, self.class.raw_hash(body)
          end

          # Builds an entity instance from the hash provided as input.
          #
          # @param hash [Hash] Hash body for parsing
          # @return [Array] constructed instances
          def json_single(hash)
            logger.debug "Converting #{hash.inspect} into a single instance" if logger_debug?
            instance = @_ib.get hash[:kind], mixins: lookup(hash[:mixins]), actions: lookup(hash[:actions])

            set_attributes! instance, hash[:attributes]
            set_links! instance, hash[:links] if instance.respond_to?(:links)
            set_target! instance, hash[:target] if instance.respond_to?(:target)

            logger.debug "Created instance #{instance.inspect}" if logger_debug?
            Set.new [instance]
          end

          # Builds entity instances from the hash provided as input.
          #
          # @param hash [Hash] Hash body for parsing
          # @return [Array] constructed instances
          def json_collection(hash)
            all = []

            logger.debug "Converting #{hash.inspect} into multiple instances" if logger_debug?
            all.concat hash[:resources] if hash[:resources]
            all.concat hash[:links] if hash[:links]
            all.map! { |a| json_single(a) }

            logger.debug "Created instances #{all.inspect}" if logger_debug?
            Set.new(all).flatten
          end

          # :nodoc:
          def lookup(ary)
            return Set.new if ary.blank?
            cats = ary.map do |item|
              handle(Occi::Core::Errors::ParsingError) { model.find_by_identifier!(item) }
            end
            Set.new cats
          end

          # :nodoc:
          def set_attributes!(instance, hash)
            return if hash.blank?
            hash.each_pair do |name, value|
              logger.debug "Setting attribute #{name} to #{value.inspect}" if logger_debug?
              attribute = instance.attributes[name.to_s]
              unless attribute
                raise Occi::Core::Errors::ParsingError,
                      "Attribute #{name.inspect} is not allowed for this entity"
              end
              attribute.value = typecast(value, attribute.attribute_definition.type)
            end
          end

          # :nodoc:
          def set_links!(instance, ary)
            return if ary.blank?
            ary.each { |l| instance.add_link(json_single(l).first) }
          end

          # :nodoc:
          def set_target!(link, hash)
            return unless link.respond_to?(:target_kind)
            return if hash.blank? || hash[:kind].blank?

            link.target_kind = lookup([hash[:kind]]).first
          end

          # :nodoc:
          def typecast(value, type)
            if value.nil? || type.nil?
              raise Occi::Core::Errors::ParsingError, 'Cannot typecast (un)set value to (un)set type'
            end
            return value unless TYPECASTER_HASH.key?(type)

            logger.debug "Typecasting value #{value.inspect} to #{type}" if logger_debug?
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
