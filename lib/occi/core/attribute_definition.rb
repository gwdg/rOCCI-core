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

      #
      def required?; end

      #
      def required!; end

      #
      def optional?; end

      #
      def optional!; end

      #
      def mutable?; end

      #
      def mutable!; end

      #
      def immutable?; end

      #
      def immutable!; end

      #
      def default?; end

      #
      def pattern?; end

      #
      def valid?(value); end

      #
      def valid!(value); end

      private

      #
      def sufficient_args!(args); end

      #
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
