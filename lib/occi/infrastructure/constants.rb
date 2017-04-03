module Occi
  module Infrastructure
    # Module containing important constats defined in OGF's Infrastructure document.
    # Here, you can find commonly used kind identifiers for `Compute`, `Network`,
    # `Storage`, and others.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Constants
      COMPUTE_KIND = 'http://schemas.ogf.org/occi/infrastructure#compute'.freeze
      NETWORK_KIND = 'http://schemas.ogf.org/occi/infrastructure#network'.freeze
      STORAGE_KIND = 'http://schemas.ogf.org/occi/infrastructure#storage'.freeze
    end
  end
end
