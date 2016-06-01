module Occi
  module Core
    module Rendering
      #
      module Renderable
        #
        def render(format, options = {}); end

        # :nodoc:
        def respond_to?(method_sym, include_private = false)
          super # TODO: change
        end

        # :nodoc:
        def methods(regular = true)
          super # TODO: change
        end

        # :nodoc:
        def public_methods(all = true)
          super # TODO: change
        end

        private

        # :nodoc:
        def method_missing(m, *args, &block)
          super # TODO: change
        end
      end
    end
  end
end
