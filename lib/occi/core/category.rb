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
      include Helpers::AttributesAccessor
      include Helpers::ArgumentValidator

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
        pre_initialize(args)
        default_args! args

        @term = args.fetch(:term)
        @schema = args.fetch(:schema)
        @title = args.fetch(:title)
        @attributes = args.fetch(:attributes)

        post_initialize(args)
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

      # Performs internal validation of the category. Returns
      # `true` or `false` depending on the result. Currently, only
      # the category identifier is used in this process.
      #
      # @example
      #   category.valid?  # => true
      #
      # @return [TrueClass] when valid
      # @return [FalseClass] when invalid
      def valid?
        # TODO: validate attribute definitions?
        self.class.valid_identifier? identifier
      end

      # Performs internal validation of the category. Raises error
      # depending on the result. Currently, only the category
      # identifier is used in this process.
      #
      # @example
      #   category.valid!
      #
      # @raise [Occi::Core::Errors::CategoryValidationError] when invalid
      def valid!
        # TODO: validate attribute definitions?
        self.class.valid_identifier! identifier
      end

      # :nodoc:
      def to_s
        identifier
      end

      # :nodoc:
      def ==(other)
        return false unless other && other.respond_to?(:identifier)
        identifier == other.identifier
      end

      # :nodoc:
      def eql?(other)
        self == other
      end

      # :nodoc:
      def hash
        identifier.hash
      end

      protected

      # :nodoc:
      def sufficient_args!(args)
        [:term, :schema].each do |attr|
          unless self.class.send("valid_#{attr}?", args[attr])
            raise Occi::Core::Errors::MandatoryArgumentError, "#{attr} is a mandatory " \
                  "argument for #{self.class}"
          end
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
      def pre_initialize(args); end

      # :nodoc:
      def post_initialize(args); end
    end
  end
end
