module Occi
  module Core
    module Renderers
      module Json
        # Implements methods common to all JSON-based renderers. This class
        # is not meant to be used directly, only as a parent to other type-specific
        # rendering classes.
        #
        # @author Boris Parak <parak@cesnet.cz
        class Base
          include Yell::Loggable
        end
      end
    end
  end
end
