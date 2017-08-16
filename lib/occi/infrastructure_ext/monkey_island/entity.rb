module Occi
  module Core
    class Entity
      # @return [Occi::Core::Mixin, NilClass] filtered mixin
      def region
        select_mixin Occi::InfrastructureExt::Mixins::Region.new
      end

      # @return [Set] filtered mixins
      def regions
        select_mixins Occi::InfrastructureExt::Mixins::Region.new
      end

      # @return [Occi::Core::Mixin, NilClass] filtered mixin
      def availability_zone
        select_mixin Occi::InfrastructureExt::Mixins::AvailabilityZone.new
      end

      # @return [Set] filtered mixins
      def availability_zones
        select_mixins Occi::InfrastructureExt::Mixins::AvailabilityZone.new
      end
    end
  end
end
