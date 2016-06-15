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

      # Methods expected on supported renderer classes
      REQUIRED_METHODS = [:renderer?, :formats, :render].freeze
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
        args.merge!(defaults) { |_, oldval, _| oldval }
        sufficient_args!(args)

        @required_methods = args.fetch(:required_methods)
        @namespace = args.fetch(:namespace)
      end

      # Lists available rendering `format`s.
      #
      # @example
      #   available_formats # => ['text', 'json', 'headers']
      #
      # @return [Array] list of formats, as Strings
      def available_formats
        available_renderers.keys
      end

      # Lists available renderers, as a Hash mapping `format` to `Renderer` class.
      #
      # @example
      #   available_renderers # => { 'text' => TextRenderer }
      #
      # @return [Hash] map of available renderers, keyed by `format`
      def available_renderers
        rcands = self.class.renderer_candidates(namespace).select do |candidate|
          self.class.renderer?(candidate, required_methods)
        end

        ravail = {}
        rcands.each do |rcand|
          rcand.formats.each { |rcand_f| ravail[rcand_f] = rcand }
        end

        ravail
      end

      # Returns a renderer corresponding with the given `format`.
      # If no such renderer exists, `nil` is returned.
      #
      # @example
      #   renderer_for 'text'   # => Occi::Core::Renderers::TextRenderer
      #   renderer_for 'tewat?' # => NilClass
      #
      # @param format [String] over-the-wire format
      # @return [Class] factory renderer corresponding to `format` or `nil`
      def renderer_for(format)
        raise Occi::Core::Errors::RenderingError,
              "Cannot return a renderer for an unspecified format" if format.blank?
        available_renderers[format]
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

        # Returns all renderer candidates from the given namespace. The list may contain
        # other constants from the given namespace and needs to be refined further.
        #
        # @param renderer_namespace [Module] base namespace
        # @return [Array] list of candidates
        def renderer_candidates(renderer_namespace)
          renderer_namespace.constants.collect { |const| renderer_namespace.const_get(const) }
        end

        # Checks whether the given object can act as a renderer.
        #
        # @example
        #   renderer? TextRenderer, [:render] # => true
        #   renderer? NilClass, [:render] # => false
        #
        # @param candidate [Object] object to check
        # @param required_methods [Array] list of required method symbols
        # @return [TrueClass, FalseClass] renderer flag
        def renderer?(candidate, required_methods)
          return false unless candidate.is_a?(Class)

          required_methods.each { |method| return false unless candidate.respond_to?(method) }
          candidate.renderer?
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
        [:required_methods, :namespace].each do |attr|
          raise Occi::Core::Errors::MandatoryArgumentError,
                "#{attr} is a mandatory argument for #{self.class}" if args[attr].blank?
        end
      end
    end
  end
end
