require 'occi/core/renderers/json/base'

module Occi
  module Core
    module Renderers
      module Json
        # Implements routines required to render `Occi::Core::Category` and
        # its subclasses to a JSON-based representation.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Category < Base; end
      end
    end
  end
end
