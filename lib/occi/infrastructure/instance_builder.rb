module Occi
  module Infrastructure
    # See `Occi::Core::InstanceBuilder` for details.
    #
    # @attr model [Occi::Infrastructure::Model] model filled with known category definitions
    #
    # @author Boris Parak <parak@cesnet.cz>
    class InstanceBuilder < Occi::Core::InstanceBuilder
      # Looks up the appropriate candidate class for the given identifier. If no class
      # is found in static tables, the last known ancestor is returned. For Core, this
      # method ALWAYS returns the last known ancestor given as `last_ancestor`, for
      # compatibility reasons.
      #
      # @param identifier [String] identifier of the category
      # @param last_ancestor [Class] expected ancestor
      # @return [Class] pre-defined class or given last ancestor
      def klass(identifier, last_ancestor)
        found_last_ancestor = self.class.klass_map[identifier]
        if found_last_ancestor && !found_last_ancestor.ancestors.include?(last_ancestor)
          raise Occi::Core::Errors::InstanceValidationError,
                "#{found_last_ancestor.inspect} is not a sub-type of #{last_ancestor.inspect}"
        end
        found_last_ancestor || last_ancestor
      end

      class << self
        # :nodoc:
        def klass_map
          {
            Occi::Infrastructure::Constants::COMPUTE_KIND => Occi::Infrastructure::Compute,
            Occi::Infrastructure::Constants::NETWORK_KIND => Occi::Infrastructure::Network,
            Occi::Infrastructure::Constants::STORAGE_KIND => Occi::Infrastructure::Storage,
            Occi::Infrastructure::Constants::SECURITY_GROUP_KIND => Occi::Infrastructure::SecurityGroup,
            Occi::Infrastructure::Constants::IPRESERVATION_KIND => Occi::Infrastructure::IPReservation,
            Occi::Infrastructure::Constants::NETWORKINTERFACE_KIND => Occi::Infrastructure::Networkinterface,
            Occi::Infrastructure::Constants::STORAGELINK_KIND => Occi::Infrastructure::Storagelink,
            Occi::Infrastructure::Constants::SECURITY_GROUP_LINK_KIND => Occi::Infrastructure::SecurityGroupLink
          }
        end
      end
    end
  end
end
