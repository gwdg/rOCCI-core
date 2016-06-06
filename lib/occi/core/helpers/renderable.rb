module Occi
  module Core
    module Helpers
      # @author Boris Parak <parak@cesnet.cz>
      module Renderable
        # Methods expected on supported renderer classes
        REQUIRED_RENDERER_METHODS = [:renderer?, :formats, :render].freeze
        # Parent namespace of all supported renderer classes
        RENDERER_NAMESPACE = Occi::Core::Renderers

        # Renders the receiver into the specified over-the-wire `format`.
        # `format` is automatically injected into `options` and these
        # are then passed (unmodified) to the underlying renderer. See
        # documentation of a specific renderer for details.
        #
        # @example
        #   kind.render 'text' # => String
        #   kind.render 'json' # => String
        #   kind.render 'headers' # => Hash
        #
        # @param format [String] over-the-wire format, mandatory
        # @param options [Hash] options passed to the underlying renderer
        # @return [Object] output of the chosen renderer
        def render(format, options = {})
          raise Occi::Core::RenderingError,
                'Rendering to an unspecified format is not allowed' if format.blank?
          options[:format] = format
          Renderable.available_renderers[format].render(self, options)
        end

        # Adds available rendering formats as `to_<format>` methods on
        # the receiver.
        #
        # @example
        #   class Test
        #     include Renderable
        #   end
        #
        #   t = Test.new
        #   t.to_text   # => String
        #
        # @param base [Class] class receiving this module
        def self.included(base)
          available_formats.each do |format|
            base.send(:define_method, "to_#{format}", proc { render(format) })
          end
        end

        # Allows calling `.extend(Renderable)` on instances. Does not allow
        # class-based extension, will raise a `RuntimeError` error.
        #
        # @example
        #   o = Object.new
        #   o.extend Renderable
        #   o.to_text  # => String
        #
        # @param base [Class, Object] class or object being extended
        def self.extended(base)
          base.is_a?(Class) ? raise("#{self} cannot extend #{base}") : included(base.class)
        end

        # Lists available rendering `format`s.
        #
        # @example
        #   available_formats # => ['text', 'json', 'headers']
        #
        # @return [Array] list of formats, as Strings
        def self.available_formats
          available_renderers.keys
        end

        # Lists available renderers, as a Hash mapping `format` to `Renderer` class.
        #
        # @example
        #   available_renderers # => { 'text' => TextRenderer }
        #
        # @return [Hash] map of available renderers, keyed by `format`
        def self.available_renderers
          rcands = renderer_candidates(renderer_namespace).select do |candidate|
            renderer?(candidate, required_renderer_methods)
          end

          ravail = {}
          rcands.each do |rcand|
            rcand.formats.each { |rcand_f| ravail[rcand_f] = rcand }
          end

          ravail
        end

        # Checks whether the given object can act as a renderer.
        #
        # @example
        #   renderer?(TextRenderer, [:renderer?, :render, :formats]) # => true
        #   renderer?(NilClass, [:renderer?, :render, :formats]) # => false
        #
        # @param candidate [Object] object to check
        # @param required_renderer_methods [Array] required method symbols
        def self.renderer?(candidate, required_renderer_methods)
          return false unless candidate.is_a?(Class)

          required_renderer_methods.each { |method| return false unless candidate.respond_to?(method) }
          candidate.renderer?
        end

        # Returns all renderer candidates from the given namespace. The list may contain
        # other constants from the given namespace and needs to be refined further.
        #
        # @param renderer_namespace [Module] base namespace
        # @return [Array] list of candidates
        def self.renderer_candidates(renderer_namespace)
          renderer_namespace.constants.collect { |const| renderer_namespace.const_get(const) }
        end

        # Lists default methods required from any supported renderer.
        #
        # @return [Array] list of method symbols
        def self.required_renderer_methods
          REQUIRED_RENDERER_METHODS
        end

        # Returns the default renderer namespace.
        #
        # @return [Module] base namespace
        def self.renderer_namespace
          RENDERER_NAMESPACE
        end
      end
    end
  end
end
