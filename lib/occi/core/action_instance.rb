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

      attr_accessor :action, :attributes

      ERRORS = [
        Occi::Core::Errors::AttributeValidationError,
        Occi::Core::Errors::AttributeDefinitionError,
        Occi::Core::Errors::InstanceValidationError
      ].freeze

      def initialize(args = {})
        args.merge!(defaults) { |_, oldval, _| oldval }
        sufficient_args!(args)

        @action = args.fetch(:action)
        @attributes = args.fetch(:attributes)
      end

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
      def valid!; end

      private

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
    end
  end
end
