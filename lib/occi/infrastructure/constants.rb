module Occi
  module Infrastructure
    # Module containing important constats defined in OGF's Infrastructure document.
    # Here, you can find commonly used kind identifiers for `Compute`, `Network`,
    # `Storage`, and others.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Constants
      # Resource sub-types
      COMPUTE_KIND        = 'http://schemas.ogf.org/occi/infrastructure#compute'.freeze
      NETWORK_KIND        = 'http://schemas.ogf.org/occi/infrastructure#network'.freeze
      STORAGE_KIND        = 'http://schemas.ogf.org/occi/infrastructure#storage'.freeze
      SECURITY_GROUP_KIND = 'http://schemas.ogf.org/occi/infrastructure#securitygroup'.freeze
      IPRESERVATION_KIND  = 'http://schemas.ogf.org/occi/infrastructure#ipreservation'.freeze

      # Link sub-types
      NETWORKINTERFACE_KIND    = 'http://schemas.ogf.org/occi/infrastructure#networkinterface'.freeze
      STORAGELINK_KIND         = 'http://schemas.ogf.org/occi/infrastructure#storagelink'.freeze
      SECURITY_GROUP_LINK_KIND = 'http://schemas.ogf.org/occi/infrastructure#securitygrouplink'.freeze

      # Mixins
      IPNETWORK_MIXIN          = 'http://schemas.ogf.org/occi/infrastructure/network#ipnetwork'.freeze
      IPNETWORKINTERFACE_MIXIN = 'http://schemas.ogf.org/occi/infrastructure/networkinterface#ipnetworkinterface'.freeze
      OS_TPL_MIXIN             = 'http://schemas.ogf.org/occi/infrastructure#os_tpl'.freeze
      RESOURCE_TPL_MIXIN       = 'http://schemas.ogf.org/occi/infrastructure#resource_tpl'.freeze
      AVAILABILITY_ZONE_MIXIN  = 'http://schemas.ogf.org/occi/infrastructure#availability_zone'.freeze
    end
  end
end
