module Occi
  module Core
    module Helpers
      # Introduces instance attribute resetting functionality to
      # the receiver. Provides methods for applying defaults and
      # adding attributes on top of existing base attributes.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module InstanceAttributeResetter
        # Returns all base attributes for this instance in the
        # form of the original hash.
        #
        # @return [Hash] hash with base attributes
        def base_attributes
          raise 'Not Implemented! You have to implement this method in the receiver.'
        end

        # Collects all available additional attributes for this
        # instance and returns them as an array.
        #
        # @return [Array] array with added attribute hashes
        def added_attributes
          raise 'Not Implemented! You have to implement this method in the receiver.'
        end

        # Shorthand for running `reset_attributes` with the `force` flag on.
        # This method will force defaults from definitions in all available
        # attributes.
        def reset_attributes!
          reset_attributes true
        end

        # Shorthand for running `reset_base_attributes` with the `force` flag on.
        # This method will force defaults from definitions in all available
        # attributes.
        def reset_base_attributes!
          reset_base_attributes true
        end

        # Shorthand for running `reset_added_attributes` with the `force` flag on.
        # This method will force defaults from definitions in all available
        # attributes.
        def reset_added_attributes!
          reset_added_attributes true
        end

        # Iterates over available attribute definitions and
        # sets corresponding fields in `attributes`. When using the `force` flag, all
        # existing attribute values will be replaced by defaults from definitions or
        # reset to `nil`.
        #
        # @param force [TrueClass, FalseClass] forcibly change attribute values to defaults
        def reset_attributes(force = false)
          reset_base_attributes force
          reset_added_attributes force
        end

        # Iterates over available base attribute definitions and
        # sets corresponding fields in `attributes`. When using the `force` flag, all
        # existing attribute values will be replaced by defaults from definitions or
        # reset to `nil`.
        #
        # @param force [TrueClass, FalseClass] forcibly change attribute values to defaults
        def reset_base_attributes(force = false)
          base_attributes.each_pair { |name, definition| reset_attribute(name, definition, force) }
        end

        # Iterates over available added attribute definitions and
        # sets corresponding fields in `attributes`. When using the `force` flag, all
        # existing attribute values will be replaced by defaults from definitions or
        # reset to `nil`.
        #
        # @param force [TrueClass, FalseClass] forcibly change attribute values to defaults
        def reset_added_attributes(force = false)
          added_attributes.each do |attrs|
            attrs.each_pair { |name, definition| reset_attribute(name, definition, force) }
          end
        end

        # Sets corresponding attribute fields in `attributes`. When using the `force` flag, any
        # existing attribute value will be replaced by the default from its definition or
        # reset to `nil`.
        #
        # @param name [String] attribute name
        # @param definition [AttributeDefinition] attribute definition
        # @param force [TrueClass, FalseClass] forcibly change attribute value to default
        def reset_attribute(name, definition, force)
          if attributes[name]
            attributes[name].attribute_definition = definition
          else
            attributes[name] = Attribute.new(nil, definition)
          end

          force ? attributes[name].default! : attributes[name].default
        end
      end
    end
  end
end
