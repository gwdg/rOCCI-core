module Occi
  module Infrastructure
    # See `Occi::Core::Model` for details.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Model < Occi::Core::Model
      # Loads OGF's OCCI Infrastructure Standard from `Occi::Infrastructure::Warehouse`.
      #
      # @example
      #    model = Occi::Infrastructure::Model.new
      #    model.load_infrastructure!
      def load_infrastructure!
        Occi::Infrastructure::Warehouse.bootstrap! self
        self << Occi::Infrastructure::Mixins::OsTpl.new
        self << Occi::Infrastructure::Mixins::ResourceTpl.new
        self << Occi::Infrastructure::Mixins::AvailabilityZone.new
        nil
      end

      # Returns an instance of `Occi::Infrastructure::InstanceBuilder` associated with this model.
      #
      # @return [Occi::Infrastructure::InstanceBuilder] instance of IB
      def instance_builder
        Occi::Infrastructure::InstanceBuilder.new(model: self)
      end
    end
  end
end
