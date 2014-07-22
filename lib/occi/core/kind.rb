module Occi
  module Core
    class Kind < Occi::Core::Category

      attr_accessor :entities, :parent, :actions

      # @param scheme [String ] The categorisation scheme.
      # @param term [String] Unique identifier of the Kind instance within the categorisation scheme.
      # @param title [String] The display name of an instance.
      # @param parent [Occi::Core::Kind,String] Another Kind instance which this Kind relates to.
      # @param actions [Occi::Core::Actions,Array] Set of Action instances defined by the Kind instance.
      # @param location [String] Location of the Kind instance.
      def initialize(scheme='http://schemas.ogf.org/occi/core#',
          term='kind',
          title=nil,
          attributes=Occi::Core::Attributes.new,
          parent=nil,
          actions=Occi::Core::Actions.new,
          location=nil)
        super(scheme, term, title, attributes)
        @parent = [parent].flatten.first
        @actions = Occi::Core::Actions.new(actions)
        @entities = Occi::Core::Entities.new
        @location = location.blank? ? "/#{term}/" : URI.parse(location).path
      end

      # @param scheme [String] The categorisation scheme.
      # @param term [String] Unique identifier of the Category instance within the categorisation scheme.
      # @param parent [Array] Another Kind instance which this Kind relates to.
      # @return [Class] Ruby class with scheme as namespace, term as name and parent kind as super class.
      def self.get_class(scheme, term, parent=Occi::Core::Entity.kind)
        parent ||= Occi::Core::Entity.kind
        raise ArgumentError, 'Mandatory argument cannot be nil' unless scheme && term

        if parent.kind_of? Array
          parent = parent.first
        end

        if parent.to_s == 'http://schemas.ogf.org/occi/core#entity'
          parent = Occi::Core::Entity.kind
        elsif parent.to_s == 'http://schemas.ogf.org/occi/core#resource'
          parent = Occi::Core::Resource.kind
        elsif parent.to_s == 'http://schemas.ogf.org/occi/core#link'
          parent = Occi::Core::Link.kind
        elsif parent.kind_of? Occi::Core::Kind
          parent = parent
        else
          parent = self.get_class(*parent.to_s.split('#')).kind
        end

        term = self.sanitize_term(term) if Occi::Settings.compatibility
        raise ArgumentError, "Invalid characters in term #{term}" unless Occi::Core::Category.valid_term?(term)

        unless scheme.end_with? '#'
          scheme << '#'
        end

        uri = URI.parse(scheme)

        if uri.host == 'schemas.ogf.org'
          namespace = uri.path.reverse.chomp('/').reverse.split('/')
        else
          namespace = uri.host.split('.').reverse + uri.path.reverse.chomp('/').reverse.split('/')
        end
        namespace.inject(Object) do |mod, name|
          if mod.constants.collect { |sym| sym.to_s }.include? name.capitalize
            namespace = mod.const_get name.capitalize
          else
            namespace = mod.const_set name.capitalize, Module.new
          end
        end

        class_name = term.classify
        if namespace.const_defined? class_name
          klass = namespace.const_get class_name
          unless klass.ancestors.include? Occi::Core::Entity
            raise "OCCI Kind with type identifier #{scheme + term} could not be created as the corresponding class #{klass.to_s} already exists and is not derived from Occi::Core::Entity"
          end
        else
          klass = namespace.const_set class_name, Class.new(parent.entity_type)
          klass.kind = Occi::Core::Kind.new scheme=scheme,
                                            term=term,
                                            title=nil,
                                            attributes={},
                                            parent=parent
        end

        klass
      end

      # Check if this Kind instance is related to another Kind instance.
      #
      # @param kind [Occi::Core::Kind, String] Kind or Type Identifier of a Kind where relation should be checked.
      # @return [true,false]
      def related_to?(kind)
        self.parent.to_s == kind.to_s or self.to_s == kind.to_s
      end

      def entity_type
        self.class.get_class self.scheme, self.term, self.parent
      end

      # set location attribute of kind
      # @param [String] location
      def location=(location)
        location = URI.parse(location).path if location
        raise "Kind locations must end with a slash!" unless location.blank? || location =~ /^\/\S+\/$/
        @location = location
      end

      def location
        @location ? @location.clone : nil
      end

      def related
        [self.parent]
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        kind = Hashie::Mash.new
        kind.parent = self.parent.to_s if self.parent
        kind.related = self.related.join(' ').split(' ') if self.related.any?
        kind.actions = self.actions.join(' ').split(' ') if self.actions.any?
        kind.location = self.location if self.location
        kind.merge! super
        kind
      end

      # @return [String] string representation of the kind
      def to_string
        string = super
        string << ";rel=#{self.related.first.to_s.inspect}" if self.related.any?
        string << ";location=#{self.location.inspect}"
        string << self.attributes.to_string_short
        string << ";actions=#{self.actions.join(' ').inspect}" if self.actions.any?
        string
      end

      private

      # Relaxed parser rules require additional checks on terms.
      def self.sanitize_term(term)
        sanitized = term.downcase.gsub(/[^a-z0-9-]/, '_').gsub(/_+/, '_').gsub(/^_|_$/, '')
        sanitized = "uuid_#{sanitized}" if sanitized.match(/^[0-9]/)

        sanitized
      end

    end
  end
end
