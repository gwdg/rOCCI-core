module Occi
  module Core
    module Renderers
      module Text
        class Base
          # Ruby 2.3 compatibility, with `$SAFE` changes
          RENDER_SAFE = (RUBY_VERSION >= '2.3') ? 1 : 3

          # Renders the given object to `text`.
          #
          # @param object [Object] instance to be rendered
          # @param options [Hash] additional options
          # @return [String] object rendering as plain text
          # @return [Hash] object rendering as hash
          def self.render(object, options)
            case options[:format]
            when 'text', 'text_plain'
              render_plain object, options
            when 'headers', 'text_occi'
              render_headers object, options
            else
              raise "Rendering to #{options[:format]} is not supported"
            end
          end

          # @return [Integer] SAFE level
          def self.render_safe
            RENDER_SAFE
          end
        end
      end
    end
  end
end
