module Occi
  module InfrastructureExt
    # Module containing important constats defined in OGF's Infrastructure Extension documents.
    # Here, you can find commonly used kind identifiers for `SecurityGroup`, `SecurityGroupLink`,
    # `IPReservation`, and others.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Constants
      # Resource sub-types
      SECURITY_GROUP_KIND = 'http://schemas.ogf.org/occi/infrastructure#securitygroup'.freeze
      IPRESERVATION_KIND  = 'http://schemas.ogf.org/occi/infrastructure#ipreservation'.freeze

      # Link sub-types
      SECURITY_GROUP_LINK_KIND = 'http://schemas.ogf.org/occi/infrastructure#securitygrouplink'.freeze

      # Mixins
      AVAILABILITY_ZONE_MIXIN  = 'http://schemas.ogf.org/occi/infrastructure#availability_zone'.freeze
      REGION_MIXIN             = 'http://schemas.ogf.org/occi/infrastructure#region'.freeze
      FLOATINGIPPOOL_MIXIN     = 'http://schemas.openstack.org/network#floatingippool'.freeze
    end
  end
end
