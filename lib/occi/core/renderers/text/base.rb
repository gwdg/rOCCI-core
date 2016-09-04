module Occi
  module Core
    module Renderers
      module Text
        class Base
          # Ruby 2.3 compatibility, with `$SAFE` changes
          RENDER_SAFE = (RUBY_VERSION >= '2.3') ? 1 : 3

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
              raise "Rendering to #{options[:format]} is not supported"
            end
          end

          # Returns an acceptable value for the $SAFE env variable
          # that should be enforced when evaluating templates.
          #
          # @return [Integer] SAFE level
          def render_safe
            RENDER_SAFE
          end
        end
      end
    end
  end
end
