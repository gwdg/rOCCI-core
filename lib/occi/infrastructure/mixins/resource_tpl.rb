module Occi
  module Infrastructure
    module Mixins
      # A helper class for manipulation with `os_tpl` parent mixin. Doesn't
      # provide any additional functionality aside from the class name.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class ResourceTpl < Occi::Core::Mixin
        TITLE = 'Resource template providing flavor/sizing information (parent mixin)'.freeze

        # See `Occi::Core::Mixin` and `Occi::Core::Category`
        def initialize
          schema, term = Occi::Infrastructure::Constants::RESOURCE_TPL_MIXIN.split('#')
          super term: term, schema: "#{schema}#", title: TITLE
        end
      end
    end
  end
end
