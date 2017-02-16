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
          !attributes[key].nil?
        end

        # :nodoc:
        def []=(key, val)
          unless attribute?(key)
            raise Occi::Core::Errors::AttributeDefinitionError, 'Attribute named ' \
                  "#{key.inspect} has not been defined for #{self}"
          end
          attributes[key].value = val
        end
      end
    end
  end
end
