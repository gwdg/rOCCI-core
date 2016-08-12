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
        # attributes. No longer defined attributes will be automatically removed.
        def reset_attributes!
          reset_attributes true
        end

        # Shorthand for running `reset_base_attributes` with the `force` flag on.
        # This method will force defaults from definitions in all available
        # attributes. No longer defined attributes will be kept unchanged.
        def reset_base_attributes!
          reset_base_attributes true
        end

        # Shorthand for running `reset_added_attributes` with the `force` flag on.
        # This method will force defaults from definitions in all available
        # attributes. No longer defined attributes will be kept unchanged.
        def reset_added_attributes!
          reset_added_attributes true
        end

        # Iterates over available attribute definitions and
        # sets corresponding fields in `attributes`. When using the `force` flag, all
        # existing attribute values will be replaced by defaults from definitions or
        # reset to `nil`. No longer defined attributes will be automatically removed.
        #
        # @param force [TrueClass, FalseClass] forcibly change attribute values to defaults
        def reset_attributes(force = false)
          reset_base_attributes force
          reset_added_attributes force
          remove_undef_attributes
        end

        # Removes attributes (definition and value) if they are no longer defined
        # for this instance. This is automatically called when invoking reset via
        # `reset_attributes` or `reset_attributes!`, in all other cases it has to
        # be triggered explicitly. Attributes without definitions will be removed
        # as well.
        #
        # @return [Hash] updated attribute hash
        def remove_undef_attributes
          name_cache = attribute_names
          attributes.keep_if { |key, value| name_cache.include?(key) && value && value.attribute_definition }
        end

        # Collects all available attribute names into a list. Without definitions
        # or values.
        #
        # @return [Array] list available attribute names
        def attribute_names
          names = added_attributes.collect(&:keys)
          names << base_attributes.keys
          names.flatten!
          names.compact!

          names
        end

        # Iterates over available base attribute definitions and
        # sets corresponding fields in `attributes`. When using the `force` flag, all
        # existing attribute values will be replaced by defaults from definitions or
        # reset to `nil`. No longer defined attributes will be kept unchanged.
        #
        # @param force [TrueClass, FalseClass] forcibly change attribute values to defaults
        def reset_base_attributes(force = false)
          base_attributes.each_pair { |name, definition| reset_attribute(name, definition, force) }
        end

        # Iterates over available added attribute definitions and
        # sets corresponding fields in `attributes`. When using the `force` flag, all
        # existing attribute values will be replaced by defaults from definitions or
        # reset to `nil`. No longer defined attributes will be kept unchanged.
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
