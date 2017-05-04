module Occi
  module InfrastructureExt
    module Mixins
      # A helper class for manipulation with `availability_zone` parent mixin. Doesn't
      # provide any additional functionality aside from the class name.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class AvailabilityZone < Occi::Core::Mixin
        TITLE = 'OCCI Availability Zone mixin'.freeze

        # See `Occi::Core::Mixin` and `Occi::Core::Category`
        def initialize
          schema, term = Occi::InfrastructureExt::Constants::AVAILABILITY_ZONE_MIXIN.split('#')
          super term: term, schema: "#{schema}#", title: TITLE
        end
      end
    end
  end
end
