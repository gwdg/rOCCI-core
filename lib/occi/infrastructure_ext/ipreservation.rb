module Occi
  module InfrastructureExt
    # Dummy sub-class of `Occi::Infrastructure::Network` meant to simplify handling
    # of known instances of the given sub-class. Does not contain any functionality.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class IPReservation < Occi::Infrastructure::Network
      # @return [Occi::Core::Mixin, NilClass] filtered mixin
      def floatingippool
        select_mixin Occi::InfrastructureExt::Mixins::Floatingippool.new
      end
    end
  end
end
