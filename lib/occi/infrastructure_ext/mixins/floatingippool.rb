module Occi
  module InfrastructureExt
    module Mixins
      # A helper class for manipulation with `floatingippool` parent mixin. Doesn't
      # provide any additional functionality aside from the class name.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class Floatingippool < Occi::Core::Mixin
        TITLE = 'OCCI Floatingippool mixin'.freeze

        # See `Occi::Core::Mixin` and `Occi::Core::Category`
        def initialize
          schema, term = Occi::InfrastructureExt::Constants::FLOATINGIPPOOL_MIXIN.split('#')
          super term: term, schema: "#{schema}#", title: TITLE
        end
      end
    end
  end
end
