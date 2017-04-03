module Occi
  module Core
    module Helpers
      # Introduces validation capabilities to every receiver
      # class. Should be used via the `extend` keyword.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module IdentifierValidator
        # Characters prohibited in `schema` attribute
        PROHIBITED_SCHEMA_CHARS = %w[% & ? ! \\].freeze

        # Definition of characters allowed in `term` attribute
        REGEXP_TERM = /^([[:alpha:]]|[[:digit:]])([[:alpha:]]|[[:digit:]]|-|_)*$/

        # Validates given `term` against the restrictions imposed by the
        # OCCI specification. See `REGEXP_TERM` in this class for details.
        #
        # @example
        #   valid_term? 'a b' # => false
        #   valid_term? 'ab'  # => true
        #
        # @param term [String] term candidate
        # @return [TrueClass, FalseClass] result
        def valid_term?(term)
          begin
            valid_term! term
          rescue Occi::Core::Errors::CategoryValidationError => ex
            logger.warn "#{self}: Term validation failed with #{ex.message}" if respond_to?(:logger)
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

          return if validation_result
          raise Occi::Core::Errors::CategoryValidationError,
                "Term #{term.inspect} does not match #{REGEXP_TERM.inspect}"
        end

        # Validates given `schema` against the restrictions imposed by the
        # URI specification. See Ruby's `URI` class for details. On top of
        # that, every schema must be terminated with '#'.
        #
        # @example
        #   valid_schema? '%^#%^'                    # => false
        #   valid_schema? 'http://example.org/test#' # => true
        #
        # @param schema [String] schema candidate
        # @return [TrueClass, FalseClass] result
        def valid_schema?(schema)
          begin
            valid_schema! schema
          rescue URI::InvalidURIError, Occi::Core::Errors::CategoryValidationError => ex
            logger.warn "#{self}: Schema validation failed with #{ex.message}" if respond_to?(:logger)
            return false
          end

          true
        end

        # Similar to `::valid_schema?`, raises an `Occi::Core::Errors::CategoryValidationError`
        # error in case of failure.
        #
        # @param schema [String] schema candidate
        def valid_schema!(schema)
          if schema.blank?
            raise Occi::Core::Errors::CategoryValidationError,
                  "Schema #{schema.inspect} cannot be blank"
          end
          unless schema.end_with?('#')
            raise Occi::Core::Errors::CategoryValidationError,
                  "Schema #{schema.inspect} must be terminated with '#'"
          end

          valid_uri! schema
          prohibited_chars! schema
        end

        # Validates given `identifier` as a combination of rules for `term`
        # and `schema`.
        #
        # @example
        #   valid_identifier? 'http://schema.org/test#a#b' # => false
        #   valid_identifier? 'http://schema.org/test#a'   # => true
        #
        # @param identifier [String] identifier candidate
        # @return [TrueClass, FalseClass] result
        def valid_identifier?(identifier)
          begin
            valid_identifier! identifier
          rescue URI::InvalidURIError, Occi::Core::Errors::CategoryValidationError => ex
            logger.warn "#{self}: Identifier validation failed with #{ex.message}" if respond_to?(:logger)
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
          if elements.count != 2
            raise Occi::Core::Errors::CategoryValidationError,
                  "Identifier #{identifier.inspect} is malformed"
          end

          valid_schema! "#{elements.first}#"
          valid_term! elements.last
        end

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
    end
  end
end
