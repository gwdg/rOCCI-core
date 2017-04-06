module Occi
  module Core
    module Parsers
      # Contains all text-related classes and modules. This
      # module houses functionality transforming various internal
      # instances from basic text-based rendering.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module Text; end
    end
  end
end

# Load class-specific parsing primitives
Dir[File.join(File.dirname(__FILE__), 'text', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi
  module Core
    module Parsers
      # Implementes components necessary to parse all required instance types
      # from `text` or `text`-like format.
      #
      # @attr model [Occi::Core::Model, Occi::Infrastructure::Model] model to use as a primary reference point
      # @attr media_type [String] type of content to parse
      #
      # @author Boris Parak <parak@cesnet.cz>
      class TextParser
        include Yell::Loggable
        include Helpers::ArgumentValidator

        # Media type constants
        URI_LIST_TYPES     = %w[text/uri-list].freeze
        HEADERS_TEXT_TYPES = %w[text/occi].freeze
        PLAIN_TEXT_TYPES   = %w[text/plain text/occi+plain].freeze
        OCCI_TEXT_TYPES    = [HEADERS_TEXT_TYPES, PLAIN_TEXT_TYPES].flatten.freeze
        MEDIA_TYPES        = [URI_LIST_TYPES, OCCI_TEXT_TYPES].flatten.freeze

        attr_accessor :model, :media_type

        # TODO: docs
        def initialize(args = {})
          pre_initialize(args)
          default_args! args

          @model = args.fetch(:model)
          @media_type = args.fetch(:media_type)

          post_initialize(args)
        end

        # TODO: docs
        def entities(body, headers, expectation); end

        # See `#entities`.
        def resources(body, headers)
          entities body, headers, Occi::Core::Resource
        end

        # See `#entities`.
        def links(body, headers)
          entities body, headers, Occi::Core::Link
        end

        # TODO: docs
        def action_instances(body, headers); end

        # TODO: docs
        def attributes(body, headers); end

        # TODO: docs
        def categories(body, headers, expectation); end

        # See `#categories`.
        def kinds(body, headers)
          categories body, headers, Occi::Core::Kind
        end

        # See `#categories`.
        def mixins(body, headers)
          categories body, headers, Occi::Core::Mixin
        end

        # See `#categories`.
        def actions(body, headers)
          categories body, headers, Occi::Core::Action
        end

        # Checks whether the given media type is supported by this
        # parser instance.
        #
        # @param media_type [String] media type string as provided by the transport protocol
        # @return [TrueClass] if supported
        # @return [FalseClass] if not supported
        def parses?(media_type)
          self.media_type == media_type
        end

        class << self
          # TODO: docs
          def model(body, headers, media_type); end

          # TODO: docs
          def locations(body, headers, media_type); end

          # Returns a list of supported media types for this parser.
          #
          # @return [Array] list of supported media types
          def media_types
            MEDIA_TYPES
          end

          # Checks whether the given media type is supported by this
          # parser.
          #
          # @param media_type [String] media type string as provided by the transport protocol
          # @return [TrueClass] if supported
          # @return [FalseClass] if not supported
          def parses?(media_type)
            media_types.include? media_type
          end
        end

        protected

        # :nodoc:
        def sufficient_args!(args)
          %i[model media_type].each do |attr|
            unless args[attr]
              raise Occi::Core::Errors::MandatoryArgumentError, "#{attr} is a mandatory " \
                    "argument for #{self.class}"
            end
          end
        end

        # :nodoc:
        def defaults
          { model: nil, media_type: nil }
        end

        # :nodoc:
        def pre_initialize(args); end

        # :nodoc:
        def post_initialize(args)
          return if OCCI_TEXT_TYPES.include?(args[:media_type])
          raise Occi::Core::Errors::ParserError, "Media type #{args[:media_type].inspect} is not supported " \
                "by instances of this parser, only #{OCCI_TEXT_TYPES.inspect}"
        end
      end
    end
  end
end
