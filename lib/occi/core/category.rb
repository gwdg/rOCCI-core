module Occi
  module Core
    #
    class Category
      attr_accessor :term, :schema, :title, :attribute_definitions

      def initialize(args = {})
        pre_initialize

        args.merge!(defaults) { |_, oldval, _| oldval }
        sufficient_args!(args)

        @term = args.fetch(:term)
        @schema = args.fetch(:schema)
        @title = args.fetch(:title)
        @attribute_definitions = args.fetch(:attribute_definitions)

        post_initialize
      end

      #
      def identifier
        "#{schema}#{term}"
      end

      #
      def valid?; end

      #
      def validate!; end

      #
      def render(format, options = {}); end

      # :nodoc:
      def empty?; end

      # :nodoc:
      def hash; end

      # :nodoc:
      def eql?(other); end

      # :nodoc:
      def ==(other); end

      # :nodoc:
      def respond_to?(method_sym, include_private = false)
        super # TODO: change
      end

      protected

      #
      def sufficient_args!(args); end

      #
      def defaults
        {
          term: nil,
          schema: nil,
          title: nil,
          attribute_definitions: nil
        }
      end

      #
      def pre_initialize; end

      #
      def post_initialize; end

      private

      # :nodoc:
      def method_missing(m, *args, &block)
        super # TODO: change
      end
    end
  end
end
