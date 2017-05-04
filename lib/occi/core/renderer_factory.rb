module Occi
  module Core
    # A singleton factory class offering convenient access to all
    # available renderer classes. Factory can be customized using
    # the `required_methods` and `namespace` attributes.
    #
    # @attr required_methods [Array] list of required renderer methods
    # @attr namespace [Module] module containing renderer candidates
    #
    # @author Boris Parak <parak@cesnet.cz>
    class RendererFactory
      include Singleton
      include Yell::Loggable
      include Helpers::ArgumentValidator

      # Methods expected on supported renderer classes
      REQUIRED_METHODS = %i[renderer? formats render].freeze
      # Parent namespace of all supported renderer classes
      NAMESPACE = Occi::Core::Renderers

      attr_accessor :required_methods, :namespace

      # Constructs an instance of the `RendererFactory` class. Since this
      # class is a singleton, `new` (or `initialize`) are not supposed to
      # be called directly. Use attribute accessors to change settings on
      # existing factories.
      #
      # @param args [Hash] hash with factory settings
      # @option args [Array] :required_methods (`REQUIRED_METHODS`) list of required renderer methods
      # @option args [Module] :namespace (`NAMESPACE`) module containing renderer candidates
      def initialize(args = {})
        default_args! args

        logger.debug "RendererFactory: Initializing with #{args.inspect}"
        @required_methods = args.fetch(:required_methods)
        @namespace = args.fetch(:namespace)

        reload!
      end

      #
      def reload!
        logger.debug 'RendererFactory: Clearing cache for renderer reload'
        @ravail_cache = nil
      end

      # Lists available rendering `format`s.
      #
      # @example
      #   formats # => ['text', 'json', 'headers']
      #
      # @return [Array] list of formats, as Strings
      def formats
        renderers.keys
      end

      # Lists available renderers as a Hash mapping `format` to `Renderer` class.
      #
      # @example
      #   renderers # => { 'text' => TextRenderer }
      #
      # @return [Hash] map of available renderers, keyed by `format`
      def renderers
        return @ravail_cache if @ravail_cache
        @ravail_cache = {}

        renderer_classes.each do |rndr_klass|
          logger.debug "RendererFactory: Registering #{rndr_klass} for #{rndr_klass.formats}"
          rndr_klass.formats.each { |rndr_klass_f| @ravail_cache[rndr_klass_f] = rndr_klass }
        end

        @ravail_cache
      end

      # Returns a renderer corresponding with the given `format`.
      # If no such renderer exists, `Occi::Core::Errors::RenderingError`
      # error is raised.
      #
      # @example
      #   renderer_for 'text'   # => Occi::Core::Renderers::TextRenderer
      #   renderer_for 'tewat?' # => !Error: Occi::Core::Errors::RenderingError!
      #
      # @param format [String] over-the-wire format
      # @return [Class] factory renderer corresponding to `format`
      def renderer_for(format)
        if format.blank?
          raise Occi::Core::Errors::RenderingError,
                'Cannot return a renderer for an unspecified format'
        end
        renderers[format] || raise(Occi::Core::Errors::RenderingError, "No renderer for #{format.inspect}")
      end

      # Lists available renderers as an Array of renderer classes.
      #
      # @example
      #   renderer_classes #=> [Occi::Core::Renderers::TextRenderer]
      #
      # @return [Array] list of renderer classes
      def renderer_classes
        self.class.classes_from(namespace).select { |cand| renderer? cand }
      end

      # Checks whether the given object can act as a renderer.
      #
      # @example
      #   renderer? TextRenderer # => true
      #   renderer? NilClass     # => false
      #
      # @param candidate [Object, Class] object or class to check
      # @return [TrueClass, FalseClass] result (`true` for renderer, else `false`)
      def renderer?(candidate)
        begin
          renderer_with_methods! candidate
          renderer_with_formats! candidate
        rescue Occi::Core::Errors::RendererError => ex
          logger.debug "RendererFactory: Renderer validation failed with #{ex.message}"
          return false
        end

        candidate.renderer?
      end

      # Ensures that the renderer candidate passed as an argument
      # exposes all required methods. If that is not the case,
      # an `Occi::Core::Errors::RendererError` error is raised.
      #
      # @param candidate [Object, Class] object or class to check
      def renderer_with_methods!(candidate)
        required_methods.each do |method|
          unless candidate.respond_to?(method)
            raise Occi::Core::Errors::RendererError, "#{candidate.inspect} " \
                  "does not respond to #{method.inspect}"
          end
        end
      end

      # Ensures that the renderer candidate passed as an argument
      # exposes supported formats. If that is not the case,
      # an `Occi::Core::Errors::RendererError` error is raised.
      #
      # @param candidate [Object, Class] object or class to check
      def renderer_with_formats!(candidate)
        unless candidate.respond_to?(:formats)
          raise Occi::Core::Errors::RendererError, "#{candidate.inspect} " \
                "does not respond to 'formats'"
        end

        return unless candidate.formats.blank?
        raise Occi::Core::Errors::RendererError, "#{candidate.inspect} " \
              'does not expose any supported formats'
      end

      class << self
        # Lists default methods required from any supported renderer.
        #
        # @return [Array] list of method symbols
        def required_methods
          REQUIRED_METHODS
        end

        # Returns the default renderer namespace.
        #
        # @return [Module] base namespace
        def namespace
          NAMESPACE
        end

        # Returns all constants from the given namespace. The list may contain
        # constants other than classes, from the given namespace and needs to
        # be refined further.
        #
        # @param namespace [Module] base namespace
        # @return [Array] list of constants
        def constants_from(namespace)
          unless namespace.is_a? Module
            raise Occi::Core::Errors::RendererError, "#{namespace.inspect} " \
                  'is not a Module'
          end
          logger.debug "RendererFactory: Looking for renderers in #{namespace}"
          namespace.constants.collect { |const| namespace.const_get(const) }
        end

        # Returns all classes from the given namespace.
        #
        # @param namespace [Module] base namespace
        # @return [Array] list of classes
        def classes_from(namespace)
          constants_from(namespace).select { |const| const.is_a? Class }
        end
      end

      private

      # :nodoc:
      def defaults
        {
          required_methods: self.class.required_methods,
          namespace: self.class.namespace
        }
      end

      # :nodoc:
      def sufficient_args!(args)
        %i[required_methods namespace].each do |attr|
          if args[attr].blank?
            raise Occi::Core::Errors::MandatoryArgumentError,
                  "#{attr} is a mandatory argument for #{self.class}"
          end
        end
      end
    end
  end
end
