module Occi
  module Core
    #
    class AttributeDefinition
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
