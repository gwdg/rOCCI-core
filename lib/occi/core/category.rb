module Occi
  module Core
    class Category

      include Occi::Helpers::Inspect

      attr_accessor :scheme, :term, :title, :attributes, :model

      def self.categories
        self.mixins + self.actions << self.kind
      end

      # @param [String ] scheme
      # @param [String] term
      # @param [String] title
      # @param [Hash] attributes
      def initialize(scheme='http://schemas.ogf.org/occi/core#',
          term='category',
          title=nil,
          attributes=Occi::Core::Attributes.new)
        @scheme = scheme
        @term = term
        @title = title
        case attributes
          when Occi::Core::Attributes
            @attributes = attributes
          else
            @attributes = Occi::Core::Attributes.parse attributes
        end
      end


      # @param [String] scheme
      # @param [String] term
      # @param [Array] related
      # @return [Class] ruby class with scheme as namespace, term as name and related kind as super class
      def self.get_class(scheme, term, parent='http://schemas.ogf.org/occi/core#entity')
        parent = parent.to_a.flatten
        scheme += '#' unless scheme.end_with? '#'

        if parent.first.to_s == 'http://schemas.ogf.org/occi/core#entity' or parent.first.nil?
          parent = Occi::Core::Entity
        elsif parent.first.kind_of? Occi::Core::Kind
          parent = parent.first.entity_type
        else
          parent = self.get_class parent.first.to_s.split('#')
        end

        uri = URI.parse(scheme)

        namespace = if uri.host == 'schemas.ogf.org'
                      uri.path.reverse.chomp('/').reverse.split('/')
                    else
                      uri.host.split('.').reverse + uri.path.reverse.chomp('/').reverse.split('/')
                    end

        namespace = namespace.inject(Object) do |mod, name|
          if mod.constants.collect { |sym| sym.to_s }.include? name.capitalize
            mod.const_get name.capitalize
          else
            mod.const_set name.capitalize, Module.new
          end
        end

        # TODO ensure class name is safe
        class_name = self.sanitize_term_before_classify(term).classify
        if namespace.const_defined? class_name
          klass = namespace.const_get class_name
          unless klass.ancestors.include? Occi::Core::Entity
            raise "OCCI Kind with type identifier #{scheme + term} could not be created as the corresponding class #{klass.to_s} already exists and is not derived from Occi::Core::Entity"
          end
        else
          klass = namespace.const_set class_name, Class.new(parent)
          klass.kind = Occi::Core::Kind.new scheme=scheme,
                                            term=term,
                                            title=nil,
                                            attributes={},
                                            parent=parent
        end

        klass
      end

      # @param [Occi::Model] model
      def model=(model)
        @related.model=model if @related
      end

      # @return [String] Type identifier of the category
      def type_identifier
        @scheme + @term
      end

      # check if category is related to another category
      # a category is related to another category
      # if it is included in @related or
      # if it is the category itself
      #
      # @param [String, Category] category Related Category or its type identifier
      # @return [true,false] true if category is related to category_id else false
      def related_to?(category)
        if @related
          self.related.each do |cat|
            return true if cat.to_s == category.to_s
          end
          return true if self.to_s == category.to_s
        end
        false
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        category = Hashie::Mash.new
        category.scheme = @scheme if @scheme
        category.term = @term if @term
        category.title = @title if @title
        category.attributes = @attributes if @attributes.any?
        category
      end

      # @return [String] short text representation of the category
      def to_string_short
        @term + ';scheme=' + @scheme.inspect + ';class=' + self.class.name.demodulize.downcase.inspect
      end

      # @return [String] full text representation of the category
      def to_string
        string = self.to_string_short
        string << ';title=' + @title.inspect if @title
        string
      end

      # @return [String] text representation
      def to_text
        'Category: ' + self.to_string
      end

      # @return [Hash] hash containing the HTTP headers of the text/occi rendering
      def to_header
        {:Category => self.to_string}
      end

      # @return [NilClass] category itself does not have a location
      def location
        nil # not implemented
      end

      def to_s
        self.type_identifier
      end

      private

      # Relaxed parser rules require additional checks on terms.
      # TODO: a better solution?
      # TODO: check for more characters
      def self.sanitize_term_before_classify(term)
        sanitized = term.downcase.gsub(/[\s\(\)\.\{\}\-;,\\\/\?\!\|\*\<\>]/, '_').gsub(/_+/, '_').chomp('_').reverse.chomp('_').reverse
        sanitized = "uuid_#{sanitized}" if sanitized.match(/^[0-9]/)

        sanitized
      end

    end
  end
end
