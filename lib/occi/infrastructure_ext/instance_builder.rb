module Occi
  module InfrastructureExt
    # See `Occi::infrastructure::InstanceBuilder` for details.
    #
    # @attr model [Occi::InfrastructureExt::Model] model filled with known category definitions
    #
    # @author Boris Parak <parak@cesnet.cz>
    class InstanceBuilder < Occi::Infrastructure::InstanceBuilder
      class << self
        # :nodoc:
        def klass_map
          ns = Occi::InfrastructureExt
          super.merge(
            ns::Constants::SECURITY_GROUP_KIND => ns::SecurityGroup,
            ns::Constants::IPRESERVATION_KIND => ns::IPReservation,
            ns::Constants::SECURITY_GROUP_LINK_KIND => ns::SecurityGroupLink
          )
        end
      end
    end
  end
end
