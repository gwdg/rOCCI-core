module Occi
  module Core
    # Contains an attribute definition, including:
    # * `type`         -- Ruby class of the desired value
    # * `required`     -- Boolean
    # * `mutable`      -- Boolean
    # * `default`      -- Depends on `type`, or `nil`
    # * `description`  -- String, or `nil`
    # * `pattern`      -- Regexp instance, or `nil`
    #
    # This definition does not carry the name of the
    # attribute or its value. These should be associated
    # with the definition by other means, e.g. in a hash
    # `{ name: definition }` or by using instances of
    # the `Occi::Core::Attribute` class.
    #
    # @example
    #   adfn = AttributeDefinition.new({
    #            type: String,
    #            required: false,
    #            mutable: true,
    #            default: nil,
    #            description: 'This is an attribute',
    #            pattern: /.*/
    #          })
    #   adfn.mutable? # => true
    #
    # @author Boris Parak <parak@cesnet.cz>
    class AttributeDefinition
      include Yell::Loggable

      attr_accessor :type, :required, :mutable,
                    :default, :description, :pattern

      def initialize(args = {})
        args.merge!(defaults) { |_, oldval, _| oldval }
        sufficient_args!(args)

        @type = args.fetch(:type)
        @required = args.fetch(:required)
        @mutable = args.fetch(:mutable)
        @default = args.fetch(:default)
        @description = args.fetch(:description)
        @pattern = args.fetch(:pattern)
      end

      # Alias with a question mark
      alias required? required
      alias mutable? mutable

      # Changes the value of `required` to `true`, in case
      # `required` is `nil` or `false`.
      #
      # @example
      #   attr_def.required? # => false
      #   attr_def.required!
      #   attr_def.required? # => true
      def required!
        self.required = true
      end

      # Shorthand for getting the negated value of `required`.
      #
      # @example
      #   attr_def.required? # => false
      #   attr_def.optional? # => true
      #
      # @return [TrueClass, FalseClass] negated value of `required`
      def optional?
        !required?
      end

      # Changes the value of `required` to `false`, in case
      # `required` is `nil` or `true`.
      #
      # @example
      #   attr_def.required? # => true
      #   attr_def.optional!
      #   attr_def.required? # => false
      def optional!
        self.required = false
      end

      # Changes the value of `mutable` to `true`, in case
      # `mutable` is `nil` or `false`.
      #
      # @example
      #   attr_def.mutable? # => false
      #   attr_def.mutable!
      #   attr_def.mutable? # => true
      def mutable!
        self.mutable = true
      end

      # Shorthand for getting the negated value of `mutable`.
      #
      # @example
      #   attr_def.mutable?   # => true
      #   attr_def.immutable? # => false
      #
      # @return [TrueClass, FalseClass] negated value of `mutable`
      def immutable?
        !mutable?
      end

      # Changes the value of `mutable` to `false`, in case
      # `mutable` is `nil` or `true`.
      #
      # @example
      #   attr_def.mutable?   # => true
      #   attr_def.immutable!
      #   attr_def.mutable?   # => false
      def immutable!
        self.mutable = false
      end

      # Indicates the presence of a default value.
      #
      # @example
      #   attr_def.default  # => nil
      #   attr_def.default? # => false
      #
      # @return [TrueClass, FalseClass] default value indicator
      def default?
        !default.nil?
      end

      # Indicates the presence of a pattern for value.
      #
      # @example
      #   attr_def.pattern  # => /.*/
      #   attr_def.pattern? # => true
      #
      # @return [TrueClass, FalseClass] pattern indicator
      def pattern?
        !pattern.nil?
      end

      # Indicates whether the given value is an acceptable
      # value for an attribute with this definition.
      #
      # @example
      #   attr_def.type       # => String
      #   attr_def.value? 5.0 # => false
      #
      # @param value [Object] candidate value
      # @return [TrueClass, FalseClass] validation result
      def valid?(value)
        begin
          valid! value
        rescue Occi::Core::Errors::AttributeValidationError => ex
          logger.debug "AttributeValidation: #{ex.message}"
          return false
        end

        true
      end

      # Indicates whether the given value is an acceptable
      # value for an attribute with this definition. This
      # method will raise an error if the given value is
      # not acceptable.
      #
      # @example
      #   attr_def.type       # => String
      #   attr_def.value! 0.5 # => Occi::Core::Errors::AttributeValidationError
      #
      # @param value [Object] candidate value
      def valid!(value)
        fail Occi::Core::Errors::AttributeValidationError,
             'No type has been defined' unless type
        fail Occi::Core::Errors::AttributeValidationError,
             "Type #{value.class} is incompatible with " \
             "defined type #{type}" unless type.ancestors.include?(value.class)

        if type.ancestors.include?(String) && pattern?
          fail Occi::Core::Errors::AttributeValidationError,
               "#{value.inspect} does not match pattern " \
               "#{pattern.inspect}" unless pattern.match(value)
        end
      end

      private

      # :nodoc:
      def sufficient_args!(args)
        fail Occi::Core::Errors::MandatoryArgumentError,
             'type is a mandatory argument' if args[:type].nil?
        fail Occi::Core::Errors::MandatoryArgumentError,
             'type must be a class' unless args[:type].is_a?(Class)

        [:required, :mutable].each do |attr|
          fail Occi::Core::Errors::MandatoryArgumentError,
               "#{attr} is a mandatory argument" if args[attr].nil?
        end
      end

      # :nodoc:
      def defaults
        {
          type: String,
          required: false,
          mutable: true,
          default: nil,
          description: nil,
          pattern: nil
        }
      end
    end
  end
end
