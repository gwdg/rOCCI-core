module Occi
  module Core
    #
    class AttributeDefinition
      attr_accessor :name, :type, :required, :mutable,
                    :default, :description, :pattern

      def initialize(args = {})
        args.merge!(defaults) { |_, oldval, _| oldval }
        sufficient_args!(args)

        @name = args.fetch(:name)
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
      def validate!(value); end

      # :nodoc:
      def hash; end

      private

      #
      def sufficient_args!(args); end

      #
      def defaults
        {
          name: nil,
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
