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
      include Rendering::Renderable

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

      class << self
        PROHIBITED_SCHEMA_CHARS = %w(% & ? ! \\).freeze

        REGEXP_ALPHA = /[a-zA-Z]/
        REGEXP_DIGIT = /[0-9]/
        REGEXP_TERM = /^(#{REGEXP_ALPHA}|#{REGEXP_DIGIT})(#{REGEXP_ALPHA}|#{REGEXP_DIGIT}|-|_)*$/

        # Validates given `term` against the restrictions imposed by the
        # OCCI specification. See `REGEXP_TERM` in this class for details.
        #
        # @example
        #   Category.valid_term? 'a b' # => false
        #   Category.valid_term? 'ab'  # => true
        #
        # @param term [String] term candidate
        # @return [TrueClass, FalseClass] result
        def valid_term?(term)
          !REGEXP_TERM.match(term).nil?
        end

        # Validates given `schema` against the restrictions imposed by the
        # URI specification. See Ruby's `URI` class for details. On top of
        # that, every schema must be terminated with '#'.
        #
        # @example
        #   Category.valid_schema? '%^#%^'                    # => false
        #   Category.valid_schema? 'http://example.org/test#' # => true
        #
        # @param schema [String] schema candidate
        # @return [TrueClass, FalseClass] result
        def valid_schema?(schema)
          !schema.blank? && valid_uri?(schema) && schema.include?('#') && !has_prohibited_chars?(schema)
        end

        # Validates given `identifier` as a combination of rules for `term`
        # and `schema`.
        #
        # @example
        #   Category.valid_identifier? 'http://schema.org/test#a#b' # => false
        #   Category.valid_identifier? 'http://schema.org/test#a'   # => true
        #
        # @param identifier [String] identifier candidate
        # @return [TrueClass, FalseClass] result
        def valid_identifier?(identifier)
          return false if identifier.blank?

          elements = identifier.split('#')
          return false if elements.count != 2

          valid_schema?("#{elements.first}#") && valid_term?(elements.last)
        end

        private

        # :nodoc:
        def valid_uri?(uri)
          begin
            URI.split(uri)
          rescue URI::InvalidURIError => ex
            logger.debug "URI validation: #{ex.message}"
            return false
          end

          true
        end

        # :nodoc:
        def has_prohibited_chars?(schema)
          PROHIBITED_SCHEMA_CHARS.collect { |char| schema.include?(char) }.reduce(:&)
        end
      end

      protected

      # :nodoc:
      def sufficient_args!(args)
        [:term, :schema].each do |attr|
          fail Occi::Core::Errors::MandatoryArgumentError,
               "#{attr} is a mandatory argument" unless self.class.send("valid_#{attr}?", args[attr])
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
