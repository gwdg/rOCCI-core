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
        # Characters prohibited in `schema` attribute
        PROHIBITED_SCHEMA_CHARS = %w(% & ? ! \\).freeze

        # Definition of characters allowed in `term` attribute
        REGEXP_TERM = /^([[:alpha:]]|[[:digit:]])([[:alpha:]]|[[:digit:]]|-|_)*$/

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
          begin
            valid_term! term
          rescue Occi::Core::Errors::CategoryValidationError => ex
            logger.warn "Category: Term validation failed with #{ex.message}"
            return false
          end

          true
        end

        # Similar to `::valid_term?`, raises an `Occi::Core::Errors::CategoryValidationError`
        # error in case of failure.
        #
        # @param term [String] term candidate
        def valid_term!(term)
          validation_result = REGEXP_TERM.match(term)
          raise Occi::Core::Errors::CategoryValidationError,
                "Term #{term.inspect} does not match #{REGEXP_TERM.inspect}" if validation_result.nil?
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
          begin
            valid_schema! schema
          rescue URI::InvalidURIError, Occi::Core::Errors::CategoryValidationError => ex
            logger.warn "Category: Schema validation failed with #{ex.message}"
            return false
          end

          true
        end

        # Similar to `::valid_schema?`, raises an `Occi::Core::Errors::CategoryValidationError`
        # error in case of failure.
        #
        # @param schema [String] schema candidate
        def valid_schema!(schema)
          raise Occi::Core::Errors::CategoryValidationError,
                "Schema #{schema.inspect} cannot be blank" if schema.blank?
          raise Occi::Core::Errors::CategoryValidationError,
                "Schema #{schema.inspect} must be terminated with '#'" unless schema.end_with?('#')

          valid_uri! schema
          prohibited_chars! schema
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
          begin
            valid_identifier! identifier
          rescue URI::InvalidURIError, Occi::Core::Errors::CategoryValidationError => ex
            logger.warn "Category: Identifier validation failed with #{ex.message}"
            return false
          end

          true
        end

        # Similar to `::valid_identifier?`, raises an `Occi::Core::Errors::CategoryValidationError`
        # error in case of failure.
        #
        # @param identifier [String] identifier candidate
        def valid_identifier!(identifier)
          elements = identifier.split('#')
          raise Occi::Core::Errors::CategoryValidationError,
                "Identifier #{identifier.inspect} is malformed" if elements.count != 2

          valid_schema! "#{elements.first}#"
          valid_term! elements.last
        end

        private

        # :nodoc:
        def valid_uri!(uri)
          URI.split uri
        end

        # :nodoc:
        def prohibited_chars!(schema)
          PROHIBITED_SCHEMA_CHARS.each do |char|
            raise "Schema #{schema.inspect} contains prohibited character #{char.inspect}" if schema.include?(char)
          end
        end
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
