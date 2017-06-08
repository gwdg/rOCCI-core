module Occi
  module Core
    module Helpers
      # Introduces rendering capabilities to every receiver
      # class. Short-hand `to_<format>` methods are automatically
      # generated for every available rendering `format`. The
      # renderability is evaluated in runtime, when calling `render`
      # or one of the `to_<format>` methods.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module Renderable
        # Default renderer factory class
        RENDERER_FACTORY_CLASS = Occi::Core::RendererFactory

        # Renders the receiver into the specified over-the-wire `format`.
        # `format` is automatically injected into `options` and these
        # are then passed (unmodified) to the underlying renderer. See
        # documentation of a specific renderer for details.
        #
        # @example
        #   render 'text' # => String
        #   render 'json' # => String
        #   render 'headers' # => Hash
        #
        # @param format [String] over-the-wire format, mandatory
        # @param options [Hash] options passed to the underlying renderer
        # @return [Object] output of the chosen renderer
        def render(format, options = {})
          options[:format] = format
          logger.debug "#{self.class} is being rendered to #{format} with #{options.inspect}" if respond_to?(:logger)
          renderer_for(format).render(self, options)
        end

        # Instance delegate for `RendererFactory#renderer_for`, see `RendererFactory`.
        def renderer_for(format)
          renderer_factory.renderer_for(format)
        end

        # Instance proxy to `renderer_factory` instance, see `Renderable::renderer_factory`.
        def renderer_factory
          Renderable.renderer_factory
        end

        # Adds available rendering formats as `to_<format>` methods on
        # the receiver.
        #
        # @example
        #   class Test
        #     include Occi::Core::Helpers::Renderable
        #   end
        #
        #   t = Test.new
        #   t.to_text   # => String
        #
        # @param base [Class] class receiving this module
        def self.included(base)
          renderer_factory.formats.each do |format|
            base.logger.debug "Adding support for format #{format} to #{base}" if base.respond_to?(:logger)
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

        # Returns pre-constructed instance of the active renderer
        # factory providing access to registered renderers.
        #
        # @return [Object] instance of the renderer factory
        def self.renderer_factory
          renderer_factory_class.instance
        end

        # Provides access to the default renderer factory class.
        #
        # @return [Class] renderer factory class
        def self.renderer_factory_class
          RENDERER_FACTORY_CLASS
        end
      end
    end
  end
end
