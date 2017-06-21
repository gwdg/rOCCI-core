module Occi
  module InfrastructureExt
    module Mixins
      # A helper class for manipulation with `region` parent mixin. Doesn't
      # provide any additional functionality aside from the class name.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class Region < Occi::Core::Mixin
        TITLE = 'OCCI Region mixin'.freeze

        # See `Occi::Core::Mixin` and `Occi::Core::Category`
        def initialize
          schema, term = Occi::InfrastructureExt::Constants::REGION_MIXIN.split('#')
          super term: term, schema: "#{schema}#", title: TITLE
        end
      end
    end
  end
end
