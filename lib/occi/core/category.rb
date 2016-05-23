module Occi
  module Core
    #
    class Category
      attr_accessor :term, :schema, :title, :attribute_definitions

      def initialize(args = {})
        pre_initialize

        args.merge!(defaults) { |_, oldval, _| oldval }
        @term = args.fetch(:term)
        @schema = args.fetch(:schema)
        @title = args.fetch(:title)
        @attribute_definitions = args.fetch(:attribute_definitions)

        post_initialize
      end

      def identifier
        "#{schema}#{term}"
      end

      def valid?; end

      def validate; end

      def validate!; end

      def render(format, options = {}); end

      def empty?; end

      def hash; end

      def eql?(object); end

      def ==(object); end

      def respond_to?(method_sym, include_private = false);
        super # TODO: change
      end

      protected

      #
      def defaults
        {
          term: nil,
          schema: nil,
          title: nil,
          attribute_definitions: AttributeDefinitions.new
        }
      end

      #
      def pre_initialize; end

      #
      def post_initialize; end

      private

      def method_missing(m, *args, &block);
        super # TODO: change
      end
    end
  end
end
