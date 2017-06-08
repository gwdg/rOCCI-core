module Occi
  module Core
    module Parsers
      # Implementes base components necessary to parse all renderings.
      #
      # @attr model [Occi::Core::Model, Occi::Infrastructure::Model] model to use as a primary reference point
      # @attr media_type [String] type of content to parse
      #
      # @abstract Not for direct use.
      # @author Boris Parak <parak@cesnet.cz>
      class BaseParser
        include Yell::Loggable
        include Helpers::ArgumentValidator
        include Helpers::ErrorHandler

        # Media type constants
        MEDIA_TYPES = [].freeze

        attr_accessor :model, :media_type

        # Shortcuts to interesting methods on logger
        DELEGATED = %i[debug? info? warn? error? fatal?].freeze
        delegate(*DELEGATED, to: :logger, prefix: true)

        # Constructs an instance of the parser that will use a particular model as the reference for every
        # parsed instance. Only instances allowed by the model will be successfuly parsed. In case of
        # `Occi::Core::Category` instances, only identifiers are parsed and existing instances from the model
        # are returned.
        #
        # @param args [Hash] constructor arguments in a Hash
        # @option args [Occi::Core::Model] :model model to use as a primary reference point
        # @option args [String] :media_type type of content to parse
        def initialize(args = {})
          pre_initialize(args)
          default_args! args

          @model = args.fetch(:model)
          @media_type = args.fetch(:media_type)
          logger.debug "Initializing parser for #{media_type.inspect}"

          post_initialize(args)
        end

        # Parses entities from the given body/headers. Only kinds, mixins, and actions already declared
        # in the model are allowed.
        #
        # @param body [String] raw `String`-like body as provided by the transport protocol
        # @param headers [Hash] raw headers as provided by the transport protocol
        # @param expectation [Class] expected class of the returned instance(s)
        # @return [Set] set of instances
        def entities(_body, _headers, _expectation = nil)
          raise Occi::Core::Errors::ParserError, 'This method needs to be implemented in subclasses'
        end

        # See `#entities`.
        def resources(body, headers)
          entities body, headers, Occi::Core::Resource
        end

        # See `#entities`.
        def links(body, headers)
          entities body, headers, Occi::Core::Link
        end

        # Parses action instances from the given body/headers. Only actions already declared in the model are
        # allowed.
        #
        # @param body [String] raw `String`-like body as provided by the transport protocol
        # @param headers [Hash] raw headers as provided by the transport protocol
        # @return [Set] set of parsed instances
        def action_instances(_body, _headers)
          raise Occi::Core::Errors::ParserError, 'This method needs to be implemented in subclasses'
        end

        # Parses categories from the given body/headers and returns corresponding instances
        # from the known model.
        #
        # @param body [String] raw `String`-like body as provided by the transport protocol
        # @param headers [Hash] raw headers as provided by the transport protocol
        # @param expectation [Class] expected class of the returned instance(s)
        # @return [Set] set of instances
        def categories(_body, _headers, _expectation = nil)
          raise Occi::Core::Errors::ParserError, 'This method needs to be implemented in subclasses'
        end

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

        # Looks up the given category identifier in the model. Unsuccessfull lookup will raise an error, as will an
        # unexpected class of the found instance.
        #
        # @param identifier [String] category identifier to look up in the model
        # @param klass [Class] expected class (raises error otherwise)
        # @return [Object] found instance
        def lookup(identifier, klass)
          found = handle(Occi::Core::Errors::ParsingError) { model.find_by_identifier!(identifier) }
          unless found.is_a?(klass)
            raise Occi::Core::Errors::ParsingError, "#{identifier.inspect} is not of expected class #{klass}"
          end
          found
        end

        class << self
          # Shortcuts to interesting methods on logger
          DELEGATED = %i[debug? info? warn? error? fatal?].freeze
          delegate(*DELEGATED, to: :logger, prefix: true)

          # Returns a list of supported media types for this parser.
          #
          # @return [Array] list of supported media types
          def media_types
            self::MEDIA_TYPES
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
          return if media_type.include?(args[:media_type])
          raise Occi::Core::Errors::ParserError, "Media type #{args[:media_type].inspect} is not supported " \
                "by instances of this parser, only #{media_type.inspect}"
        end
      end
    end
  end
end
