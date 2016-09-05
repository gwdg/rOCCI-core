module Occi
  module Core
    module Renderers
      module Text
        # Implements methods common to all text-based renderers. This class
        # is not meant to be used directly, only as a parent to other type-specific
        # rendering classes.
        #
        # @author Boris Parak <parak@cesnet.cz
        class Base
          include Yell::Loggable

          # Ruby 2.3 compatibility, with `$SAFE` changes
          RENDER_SAFE = RUBY_VERSION >= '2.3' ? 1 : 3

          attr_accessor :object, :options

          # Constructs a renderer instance for the given
          # object.
          #
          # @param object [Object] instance to be rendered
          # @param options [Hash] additional options
          def initialize(object, options)
            @object = object
            @options = options
          end

          # Renders the given object to `text`.
          #
          # @return [String] object rendering as plain text
          # @return [Hash] object rendering as hash
          def render
            case options[:format]
            when 'text', 'text_plain'
              render_plain
            when 'headers', 'text_occi'
              render_headers
            else
              raise Occi::Core::Errors::RenderingError,
                    "Rendering to #{options[:format]} is not supported"
            end
          end

          # Returns an acceptable value for the $SAFE env variable
          # that should be enforced when evaluating templates.
          #
          # @return [Integer] SAFE level
          def render_safe
            RENDER_SAFE
          end

          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain; end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers; end
        end
      end
    end
  end
end
