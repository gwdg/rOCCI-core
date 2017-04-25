module Occi
  module Core
    module Parsers
      # Contains all JSON-related classes and modules. This
      # module houses functionality transforming various internal
      # instances from basic JSON rendering.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module Json; end
    end
  end
end

# Load class-specific parsing primitives
Dir[File.join(File.dirname(__FILE__), 'json', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi
  module Core
    module Parsers
      # Implementes components necessary to parse all required instance types
      # from `JSON` or `JSON`-like format.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class JsonParser < BaseParser
        # Media type constants
        MEDIA_TYPES = %w[application/occi+json application/json].freeze

        # Parses entities from the given body/headers. Only kinds, mixins, and actions already declared
        # in the model are allowed.
        #
        # @param body [String] raw `String`-like body as provided by the transport protocol
        # @param headers [Hash] raw headers as provided by the transport protocol
        # @param expectation [Class] expected class of the returned instance(s)
        # @return [Set] set of instances
        def entities(_body, _headers = nil, _expectation = nil)
          # expectation ||= Occi::Core::Entity
          Set.new([])
        end

        # Parses action instances from the given body/headers. Only actions already declared in the model are
        # allowed.
        #
        # @param body [String] raw `String`-like body as provided by the transport protocol
        # @param headers [Hash] raw headers as provided by the transport protocol
        # @return [Set] set of parsed instances
        def action_instances(_body, _headers = nil)
          Set.new([])
        end

        # Parses categories from the given body/headers and returns corresponding instances
        # from the known model.
        #
        # @param body [String] raw `String`-like body as provided by the transport protocol
        # @param headers [Hash] raw headers as provided by the transport protocol
        # @param expectation [Class] expected class of the returned instance(s)
        # @return [Set] set of instances
        def categories(_body, _headers = nil, _expectation = nil)
          # expectation ||= Occi::Core::Category
          Set.new([])
        end

        class << self
          # Extracts categories from body and headers. For details, see `Occi::Core::Parsers::Json::Category`.
          #
          # @param body [String] raw `String`-like body as provided by the transport protocol
          # @param headers [Hash] raw headers as provided by the transport protocol
          # @param media_type [String] media type string as provided by the transport protocol
          # @param model [Occi::Core::Model] `Model`-like instance to be populated (may contain existing categories)
          # @return [Occi::Core::Model] model instance filled with parsed categories
          def model(_body, _headers, media_type, model)
            unless media_types.include?(media_type)
              raise Occi::Core::Errors::ParsingError,
                    "#{self} -> model cannot be parsed from #{media_type.inspect}"
            end
            model
          end

          # Extracts URI-like locations from body and headers. For details, see `Occi::Core::Parsers::Json::Location`.
          #
          # @param body [String] raw `String`-like body as provided by the transport protocol
          # @param headers [Hash] raw headers as provided by the transport protocol
          # @param media_type [String] media type string as provided by the transport protocol
          # @return [Array] list of extracted URIs
          def locations(_body, _headers, media_type)
            unless media_types.include?(media_type)
              raise Occi::Core::Errors::ParsingError,
                    "#{self} -> locations cannot be parsed from #{media_type.inspect}"
            end
            []
          end
        end
      end
    end
  end
end
