module Occi
  module Core
    # Module containing important constats defined in OGF's Core document.
    # Here, you can find commonly used kind identifiers for `Entity`, `Resource`,
    # and `Link`.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Constants
      ENTITY_KIND   = 'http://schemas.ogf.org/occi/core#entity'.freeze
      RESOURCE_KIND = 'http://schemas.ogf.org/occi/core#resource'.freeze
      LINK_KIND     = 'http://schemas.ogf.org/occi/core#link'.freeze
    end
  end
end
