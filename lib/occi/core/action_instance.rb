module Occi
  module Core
    # Class representing executable instances of actions. Every instance carries the original
    # action definition (instance of `Action`) together with attributes chosen for this
    # invocation of the action. Validity of `ActionInstance` instances is determined by
    # the validity of included `Action` instance and validity of provided attribute values.
    #
    # @attr action [Action] original action definition
    # @attr attributes [Hash] attributes for this action instance
    #
    # @author Boris Parak <parak@cesnet.cz>
    class ActionInstance
      include Yell::Loggable
      include Helpers::Renderable
      include Helpers::InstanceAttributesAccessor
      include Helpers::ArgumentValidator
      include Helpers::InstanceAttributeResetter

      attr_accessor :action, :attributes

      ERRORS = [
        Occi::Core::Errors::AttributeValidationError,
        Occi::Core::Errors::AttributeDefinitionError,
        Occi::Core::Errors::InstanceValidationError
      ].freeze

      def initialize(args = {})
        default_args! args

        @action = args.fetch(:action)
        @attributes = args.fetch(:attributes)

        reset_attributes
      end

      # Assigns new action instance to this action instance. This
      # method will trigger a complete reset on all previously
      # set attributes, for the sake of consistency.
      #
      # @param action [Occi::Core::Action] action to be assigned
      # @return [Occi::Core::Action] assigned action
      def action=(action)
        raise Occi::Core::Errors::InstanceValidationError,
              'Missing valid action' unless action

        @action = action
        reset_attributes!

        action
      end
      alias kind action
      alias kind= action=

      # Checks whether this action instance is valid. Validity
      # is determined by the validity of the included action
      # object and attribute value(s).
      #
      # @return [TrueClass] if valid
      # @return [FalseClass] if invalid
      def valid?
        begin
          valid!
        rescue *ERRORS => ex
          logger.warn "ActionInstance invalid: #{ex.message}"
          return false
        end

        true
      end

      # Checks whether this action instance is valid. Validity
      # is determined by the validity of the included action
      # object and attribute value(s). This method will raise
      # an error when the validation fails.
      #
      # @raise [Errors::AttributeValidationError] if attribute(s) are invalid
      # @raise [Errors::AttributeDefinitionError] if attribute defs are missing
      # @raise [Occi::Core::Errors::InstanceValidationError] if this instance is invalid
      def valid!
        raise Occi::Core::Errors::InstanceValidationError, 'Missing valid action object' unless action
        raise Occi::Core::Errors::InstanceValidationError, 'Missing valid attributes object' unless attributes

        attributes.each_pair { |name, attribute| valid_attribute!(name, attribute) }
      end

      private

      # Returns all base attributes for this instance in the
      # form of the original hash.
      #
      # @return [Hash] hash with base attributes
      def base_attributes
        action.attributes
      end

      # Collects all available additional attributes for this
      # instance and returns them as an array.
      #
      # @return [Array] array with added attribute hashes
      def added_attributes
        []
      end

      # :nodoc:
      def sufficient_args!(args)
        [:action, :attributes].each do |attr|
          raise Occi::Core::Errors::MandatoryArgumentError, "#{attr} is a mandatory " \
                "argument for #{self.class}" unless args[attr]
        end
      end

      # :nodoc:
      def defaults
        {
          action: nil,
          attributes: {}
        }
      end

      # :nodoc:
      def valid_attribute!(name, attribute)
        attribute.valid!
      rescue => ex
        raise ex, "Attribute #{name.inspect} invalid: #{ex}", ex.backtrace
      end
    end
  end
end
