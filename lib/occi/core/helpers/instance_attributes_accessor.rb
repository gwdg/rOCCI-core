module Occi
  module Core
    module Helpers
      # Introduces instance attributes accessor as a shortcut to
      # getting to the `attributes` values inside the receiver.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module InstanceAttributesAccessor
        # :nodoc:
        def [](key)
          attribute?(key) ? attributes[key].value : nil
        end

        # :nodoc:
        def attribute?(key)
          attributes.key?(key)
        end

        # :nodoc:
        def []=(key, val)
          raise Occi::Core::Errors::AttributeDefinitionError, 'Attribute named ' \
                "#{key.inspect} has not been defined for #{self}" unless attribute?(key)
          attributes[key].value = val
        end
      end
    end
  end
end
