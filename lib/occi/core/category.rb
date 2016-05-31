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
        PROHIBITED_SCHEMA_CHARS = %w(% & ? ! \\).freeze

        REGEXP_ALPHA = /[a-zA-Z]/
        REGEXP_DIGIT = /[0-9]/
        REGEXP_TERM = /(#{REGEXP_ALPHA}|#{REGEXP_DIGIT})(#{REGEXP_ALPHA}|#{REGEXP_DIGIT}|-|_)*/

        #
        def valid_term?(term)
          !term.blank? && REGEXP_TERM.match(term)
        end

        #
        def valid_schema?(schema)
          !schema.blank? && valid_uri?(schema) && schema.include?('#') && !has_prohibited_chars?(schema)
        end

        #
        def valid_identifier?(identifier)
          return false if identifier.blank?

          schema, term = identifier.split('#')
          valid_schema?(schema) && valid_term?(term)
        end

        #
        def valid_uri?(uri)
          begin
            URI.split(uri)
          rescue URI::InvalidURIError => ex
            logger.debug "URI validation: #{ex.message}"
            return false
          end

          true
        end

        private

        #
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
