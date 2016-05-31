module Occi
  module Core
    #
    class Category
      #
      include Rendering::Renderable

      attr_accessor :term, :schema, :title, :attributes

      def initialize(args = {})
        pre_initialize

        args.merge!(defaults) { |_, oldval, _| oldval }
        sufficient_args!(args)

        @term = args.fetch(:term)
        @schema = args.fetch(:schema)
        @title = args.fetch(:title)
        @attributes = args.fetch(:attributes)

        post_initialize
      end

      #
      def identifier
        "#{schema}#{term}"
      end

      # :nodoc:
      def to_s
        identifier
      end

      # :nodoc:
      def [](key)
        attributes[key]
      end

      # :nodoc:
      def []=(key, val)
        attributes[key] = val
      end

      class << self
        #
        def valid_term?(term); end

        #
        def valid_schema?(schema); end

        #
        def valid_identifier?(identifier); end
      end

      protected

      # :nodoc:
      def sufficient_args!(args)
        [:term, :schema].each do |attr|
          fail Occi::Core::Errors::MandatoryArgumentError,
               "#{attr} is a mandatory argument" if args[attr].nil?
        end
      end

      # :nodoc:
      def defaults
        {
          term: nil,
          schema: nil,
          title: nil,
          attributes: {}
        }
      end

      # :nodoc:
      def pre_initialize; end

      # :nodoc:
      def post_initialize; end
    end
  end
end
