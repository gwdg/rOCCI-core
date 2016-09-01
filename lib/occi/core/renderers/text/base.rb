module Occi
  module Core
    module Renderers
      module Text
        class Base
          class <<self
            # Renders the given object to `text`.
            #
            # @param object [Object] instance to be rendered
            # @param options [Hash] additional options
            # @return [String] object rendering
            def render(object, options); end
          end
        end
      end
    end
  end
end
