module Occi
  module Core
    class Entity

      include Occi::Helpers::Inspect
      include Occi::Helpers::Comparators::Entity

      attr_accessor :mixins, :attributes, :actions, :id, :model, :location
      attr_reader :kind

      class_attribute :kind, :mixins, :attributes, :actions

      self.mixins = Occi::Core::Mixins.new

      self.attributes = Occi::Core::Attributes.new
      self.attributes['occi.core.id'] = {:pattern => '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'}
      self.attributes['occi.core.title'] = {:mutable => true}

      self.kind = Occi::Core::Kind.new scheme='http://schemas.ogf.org/occi/core#',
                                       term='entity',
                                       title='entity',
                                       attributes=self.attributes

      # @return [String]
      def self.type_identifier
        self.kind.type_identifier
      end

      # @param [Array] args list of arguments
      # @return [Object] new instance of this class
      def self.new(*args)
        if args.size > 0
          type_identifier = args[0].to_s
          related = [self.kind]
        else
          type_identifier = self.kind.type_identifier
          related = nil
        end
        scheme, term = type_identifier.split '#'

        klass = Occi::Core::Kind.get_class scheme, term, related

        object = klass.allocate
        object.send :initialize, *args
        object
      end

      def self.attribute_properties
        attributes = Occi::Core::Attributes.new self.attributes
        attributes.merge! Occi::Core::Attributes.new(self.superclass.attribute_properties) if self < Occi::Core::Entity
        attributes
      end

      def attribute_properties
        attributes = self.class.attribute_properties
        @mixins.collect {|mixin| attributes.merge! Occi::Core::Attributes.new(mixin.attributes)}
        attributes
      end

      # @param [String] kind
      # @param [String] mixins
      # @param [Occi::Core::Attributes] attributes
      # @param [Occi::Core::Actions] actions
      # @return [Occi::Core::Entity]
      def initialize(kind = self.kind, mixins=[], attributes={}, actions=[], location=nil)
        @kind = self.class.kind.clone
        @mixins = Occi::Core::Mixins.new mixins
        @mixins.entity = self

        attributes = self.class.attribute_properties if attributes.blank?
        if attributes.kind_of? Occi::Core::Attributes
          @attributes = attributes.convert
        else
          @attributes = Occi::Core::Attributes.new attributes
        end
        @attributes['occi.core.id'] ||= UUIDTools::UUID.random_create.to_s

        @actions = Occi::Core::Actions.new actions
        @location = location
      end

      # @param [Occi::Core::Kind,String] kind
      # @return [Occi::Core::Kind]
      def kind=(kind)
        if kind.kind_of? String
          scheme, term = kind.split '#'
          kind = Occi::Core::Kind.get_class scheme, term
        end
        @kind = kind
      end

      # @param [Array] mixins
      def mixins=(mixins)
        @mixins = Occi::Core::Mixins.new mixins
        @mixins.entity = self
        @mixins
      end

      # @param [Occi::Core::Attributes] attributes
      def attributes=(attributes)
        @attributes = Occi::Core::Attributes.new attributes
      end

      # @param [Occi::Core::Actions] actions
      def actions=(actions)
        @actions = Occi::Core::Actions.new actions
      end

      # set id for entity
      # @param [UUIDTools::UUID] id
      def id=(id)
        @attributes.occi!.core!.id = id
        @id = id
      end

      # @return [UUIDTools::UUID] id of the entity
      def id
        @id ||= @attributes.occi_.core_.id
        @id
      end

      # set title attribute for entity
      # @param [String] title
      def title=(title)
        @attributes.occi!.core!.title = title
      end

      # @return [String] title attribute of entity
      def title
        @attributes.occi_.core_.title
      end

      # @param [Occi::Model] model
      # @return [Occi::Model]
      def model=(model)
        @model = model

        @kind = (model.get_by_id(@kind.type_identifier) || @kind)
        @kind.entities << self

        @mixins.model = model
        @mixins.each { |mixin| mixin.entities << self }

        @actions.model = model
      end

      # set location attribute of entity
      # @param [String] location
      def location=(location)
        @location = location
      end

      # @return [String] location of the entity
      def location
        return @location if @location
        "#{kind.location}#{id.gsub('urn:uuid:', '')}" if id
      end

      # check attributes against their definitions and set defaults
      # @param [true,false] set default values for all empty attributes
      def check(set_defaults = false)

        raise ArgumentError, 'No model has been assigned to this entity' unless @model # XXX: Needs error type
 
        kind = @model.get_by_id(@kind.to_s)
        raise Occi::Errors::KindNotDefinedError, "Kind not found for entity #{self.to_s}!" unless kind # XXX: Needs error type
 
        definitions = Occi::Core::Attributes.new
        definitions.merge! kind.attributes
 
        @mixins.each do |mxn|
          mixin = @model.get_by_id(mxn.to_s)
          next if mixin.nil?
 
          definitions.merge!(mixin.attributes) if mixin.attributes
        end if @mixins
 
        @attributes.check!(definitions, set_defaults)
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        entity = Hashie::Mash.new
        entity.kind = @kind.to_s if @kind
        entity.mixins = @mixins.join(' ').split(' ') if @mixins.any?
        entity.actions = @actions.as_json if @actions.any?
        entity.attributes = @attributes.as_json if @attributes.as_json.any?
        entity.id = id.to_s if id
        entity
      end

      # @return [String] text representation
      def to_text
        text = "Category: #{self.kind.term};scheme=#{self.kind.scheme.inspect};class=\"kind\""
        @mixins.each do |mixin|
          scheme, term = mixin.to_s.split('#')
          scheme << '#'
          text << "\nCategory: #{term};scheme=#{scheme.inspect};class=\"mixin\""
        end

        text << @attributes.to_text

        @actions.each { |action| text << "\nLink: <#{self.location}?action=#{action.term}>;rel=#{action.to_s}" }

        text
      end

      # @return [Hash] hash containing the HTTP headers of the text/occi rendering
      def to_header
        header = Hashie::Mash.new
        header['Category'] = "#{self.kind.term};scheme=#{self.kind.scheme.inspect};class=\"kind\""

        @mixins.each do |mixin|
          scheme, term = mixin.to_s.split('#')
          scheme << '#'
          header['Category'] << ",#{term};scheme=#{scheme.inspect};class=\"mixin\""
        end

        attributes = @attributes.to_header
        header['X-OCCI-Attribute'] = attributes unless attributes.blank?

        links = []
        @actions.each { |action| links << "<#{self.location}?action=#{action.term}>;rel=#{action.to_s}" }
        header['Link'] = links.join(',') if links.any?

        header
      end

      # @return [String] string representation of entity is its location
      def to_s
        self.location
      end

      # @return [Bool] Indicating whether this entity is "empty", i.e. required attributes are blank
      def empty?
        kind.blank? || attributes['occi.core.id'].blank?
      end

    end
  end
end
