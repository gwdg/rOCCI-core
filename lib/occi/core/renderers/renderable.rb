module Occi
  module Core
    module Renderers
      #
      module Renderable
        #
        def render(format, options = {}); end

        #
        def self.included(mod); end
      end
    end
  end
end
