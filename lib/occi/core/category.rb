module Occi
  module Core
    # Implements the base class for all OCCI categories, including
    # `Kind`, `Action`, and `Mixin`.
    #
    # @attr term [String] category term
    # @attr schema [String] category schema, ending with '#'
    # @attr title [String] category title
    # @attr attributes [Hash] category attributes
    #
    # @attr_reader identifier [String] full identifier constructed from term and schema
    #
    # @abstract The base class itself is not renderable and should be
    #           used as an abstract starting point.
    # @author Boris Parak <parak@cesnet.cz>
    class Category
      include Yell::Loggable
      include Helpers::Renderable
      extend Helpers::IdentifierValidator

      attr_accessor :term, :schema, :title, :attributes

      # Constructs an instance with the given category information.
      # Both `term` and `schema` are mandatory arguments. `schema` must
      # be terminated with '#'.
      #
      # @example
      #   Category.new term: 'gnr', schema: 'http://example.org/test#'
      #
      # @param args [Hash] arguments with category information
      # @option args [String] :term category term
      # @option args [String] :schema category schema, ending with '#'
      # @option args [String] :title (nil) category title
      # @option args [Hash] :attributes (Hash) category attributes
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

      # Returns a full category identifier constructed from
      # `term` and `schema`.
      #
      # @example
      #   category.identifier  # => 'http://example.org/test#gnr'
      #
      # @return [String] category identifier
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

      protected

      # :nodoc:
      def sufficient_args!(args)
        [:term, :schema].each do |attr|
          raise Occi::Core::Errors::MandatoryArgumentError, "#{attr} is a mandatory " \
                "argument for #{self.class}" unless self.class.send("valid_#{attr}?", args[attr])
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
