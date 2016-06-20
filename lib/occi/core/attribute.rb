module Occi
  module Core
    # Represents an attribute commonly used in instances based on
    # `Entity` or `ActionInstance`. In most cases, instances of this
    # class will carry the attribute `value` and the `attribute_definition`
    # used for validation purposes. Attributes without `value` will default
    # to the value specified by `attribute_definition.default`, if present.
    # Attributes without `attribute_definition` are considered invalid.
    #
    # @attr value [Object] value of this attribute instance
    # @attr attribute_definition [AttributeDefinition] definition of this attribute instance
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Attribute < Struct.new(:value, :attribute_definition)
      include Yell::Loggable

      # Checks whether the `value` assigned to this instance
      # does not violate restrictions defined in `attribute_definition`.
      # Attributes without `attribute_definition` are considered
      # invalid. Attributes without `value` may be considered valid
      # depending on the content on `attribute_definition`.
      #
      # @return [TrueClass, FalseClass] validation result
      def valid?
        begin
          valid!
        rescue Occi::Core::Errors::AttributeValidationError, Occi::Core::Errors::AttributeDefinitionError => ex
          logger.warn "Attribute invalid: #{ex.message}"
          return false
        end

        true
      end

      # Checks whether the `value` assigned to this instance
      # does not violate restrictions defined in `attribute_definition`.
      # Attributes without `attribute_definition` are considered
      # invalid. Attributes without `value` may be considered valid
      # depending on the content on `attribute_definition`.
      # This method will raise an `Occi::Core::Errors::AttributeValidationError`
      # error on failure.
      #
      # @raise [Occi::Core::Errors::AttributeDefinitionError] if there are problems with the definition
      # @raise [Occi::Core::Errors::AttributeValidationError] if this instance is not valid
      def valid!
        raise Occi::Core::Errors::AttributeValidationError,
              'Attribute is missing a definition' unless definition?
        raise Occi::Core::Errors::AttributeDefinitionError,
              'Attribute definition is not capable of validation' unless attribute_definition.respond_to?(:valid!)

        attribute_definition.valid! value
      end

      # Checks whether this instance has `attribute_definition` assigned.
      #
      # @return [TrueClass, FalseClass] flag indicating the presence of `attribute_definition`
      def definition?
        !attribute_definition.nil?
      end
      alias attribute_definition? definition?

      # Checks whether this instance has `value` assigned. Attributes in which
      # `nil` is an acceptable value will still be considered valueless, although
      # the validation may pass, see `#valid?` or `#valid!`.
      #
      # @return [TrueClass, FalseClass] flag indicating the presence of `value`
      def value?
        !value.nil?
      end

      # Checks whether this instance has both `value` and `attribute_definition` assigned.
      # For details, see `#definition?` and `#value?`.
      #
      # @return [TrueClass, FalseClass] flag indicating the presence of `attribute_definition` and `value`
      def full?
        definition? && value?
      end

      # Checks whether this instance is missing both `value` and `attribute_definition`.
      #
      # @return [TrueClass, FalseClass] flag indicating emptiness
      def empty?
        !(definition? || value?)
      end

      # Gracefully sets `value` for this instance from the default value specified
      # in `attribute_definition`. Only `value` set to `nil` will be replaced, other
      # values will be kept. In case `nil` is the default value, it will be set
      # and reported as a new value. An attempt to change the value will be made only
      # if there is no current value (instance with a `value` but no `attribute_definition`
      # will pass this method without raising an error).
      #
      # @raise [Occi::Core::Errors::AttributeDefinitionError] if there is no `attribute_definition`
      # @return [Object] new value, if changed
      # @return [NilClass] if nothing changed
      def default
        value? ? nil : default!
      end

      # Sets `value` for this instance from the default value specified
      # in `attribute_definition`. This method will OVERWRITE any previous
      # `value` present in this instance. See `#default` for the graceful
      # version.
      #
      # @raise [Occi::Core::Errors::AttributeDefinitionError] if there is no `attribute_definition`
      # @return [Object] new value
      def default!
        raise Occi::Core::Errors::AttributeDefinitionError,
              'There is no definition for this attribute' unless definition?
        self.value = attribute_definition.default
      end

      # Resets the value of this attribute instance to `nil`.
      #
      # @return [NilClass] always `nil`
      def reset!
        self.value = nil
      end
    end
  end
end
