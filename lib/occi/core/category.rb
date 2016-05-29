module Occi
  module Core
    #
    class Category
      #
      include Rendering::Renderable

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
      def [](key)
        attribute_definitions[key]
      end

      #
      def []=(key, val)
        attribute_definitions[key] = val
      end

      # :nodoc:
      def empty?; end

      # :nodoc:
      def hash; end

      # :nodoc:
      def eql?(other); end

      # :nodoc:
      def ==(other); end

      protected

      #
      def sufficient_args!(args); end

      #
      def defaults
        {
          term: nil,
          schema: nil,
          title: nil,
          attribute_definitions: {}
        }
      end

      #
      def pre_initialize; end

      #
      def post_initialize; end
    end
  end
end
