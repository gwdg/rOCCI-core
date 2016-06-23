module Occi
  module Core
    module Helpers
      # Introduces attributes accessor as a shortcut to
      # getting to the `attributes` values inside the
      # receiver.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module AttributesAccessor
        # :nodoc:
        def [](key)
          attributes[key]
        end

        # :nodoc:
        def []=(key, val)
          attributes[key] = val
        end
      end
    end
  end
end
