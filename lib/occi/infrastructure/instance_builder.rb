module Occi
  module Infrastructure
    # See `Occi::Core::InstanceBuilder` for details.
    #
    # @attr model [Occi::Infrastructure::Model] model filled with known category definitions
    #
    # @author Boris Parak <parak@cesnet.cz>
    class InstanceBuilder < Occi::Core::InstanceBuilder
      class << self
        # :nodoc:
        def klass_map
          ns = Occi::Infrastructure
          super.merge(
            ns::Constants::COMPUTE_KIND => ns::Compute,
            ns::Constants::NETWORK_KIND => ns::Network,
            ns::Constants::STORAGE_KIND => ns::Storage,
            ns::Constants::NETWORKINTERFACE_KIND => ns::Networkinterface,
            ns::Constants::STORAGELINK_KIND => ns::Storagelink
          )
        end
      end
    end
  end
end
