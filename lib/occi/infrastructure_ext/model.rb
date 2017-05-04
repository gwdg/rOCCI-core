module Occi
  module InfrastructureExt
    # See `Occi::Infrastructure::Model` for details.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Model < Occi::Infrastructure::Model
      # Loads OGF's OCCI Infrastructure Ext Standard from `Occi::InfrastructureExt::Warehouse`.
      #
      # @example
      #    model = Occi::InfrastructureExt::Model.new
      #    model.load_infrastructure_ext!
      def load_infrastructure_ext!
        Occi::InfrastructureExt::Warehouse.bootstrap! self
        self << Occi::InfrastructureExt::Mixins::AvailabilityZone.new
        nil
      end

      # Returns an instance of `Occi::InfrastructureExt::InstanceBuilder` associated with this model.
      #
      # @return [Occi::InfrastructureExt::InstanceBuilder] instance of IB
      def instance_builder
        Occi::InfrastructureExt::InstanceBuilder.new(model: self)
      end
    end
  end
end
