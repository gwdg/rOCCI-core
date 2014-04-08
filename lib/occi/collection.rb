module Occi
  class Collection

    include Occi::Helpers::Inspect
    include Occi::Helpers::Comparators::Collection

    attr_accessor :kinds, :mixins, :actions, :resources, :links, :action, :model

    # Initialize a new OCCI Collection by initializing all supplied OCCI objects
    #
    # @param [Hash] collection including one or more of the keys kinds, mixins, actions, resources, links
    def initialize(collection={}, model = Occi::Model.new)
      collection = Hashie::Mash.new(collection) unless collection.kind_of? Occi::Collection

      @kinds = Occi::Core::Kinds.new
      @mixins = Occi::Core::Mixins.new
      @actions = Occi::Core::Actions.new
      @resources = Occi::Core::Resources.new
      @links = Occi::Core::Links.new

      @kinds.merge collection.kinds.to_a.collect { |kind| Occi::Core::Kind.new(kind.scheme, kind.term, kind.title, kind.attributes, kind.related, kind.actions, kind.location) }
      @mixins.merge collection.mixins.to_a.collect { |mixin| Occi::Core::Mixin.new(mixin.scheme, mixin.term, mixin.title, mixin.attributes, mixin.depends, mixin.actions, mixin.location, mixin.applies) }
      @actions.merge collection.actions.to_a.collect { |action| Occi::Core::Action.new(action.scheme, action.term, action.title, action.attributes) }
      @resources.merge collection.resources.to_a.collect { |resource| Occi::Core::Resource.new(resource.kind, resource.mixins, resource.attributes, resource.actions, resource.links, resource.location) }
      @links.merge collection.links.to_a.collect { |link| Occi::Core::Link.new(link.kind, link.mixins, link.attributes, link.actions, link.rel, link.target, link.source, link.location) }
      @action = Occi::Core::ActionInstance.new(collection.action.action, collection.action.attributes) if collection.action

      self.model = model if model
    end

    def <<(object)
      self.kinds << object if object.kind_of? Occi::Core::Kind
      self.mixins << object if object.kind_of? Occi::Core::Mixin
      self.actions << object if object.kind_of? Occi::Core::Action
      self.resources << object if object.kind_of? Occi::Core::Resource
      self.links << object if object.kind_of? Occi::Core::Link

      self.action = object if object.kind_of? Occi::Core::ActionInstance

      self
    end

    # @return [Occi::Core::Categories] categories combined list of all kinds, mixins and actions
    def categories
      Occi::Core::Categories.new(@kinds + @mixins + @actions)
    end

    # @return [Occi::Core::Entities] entities combined list of all resources and links
    def entities
      Occi::Core::Entities.new(@resources + @links)
    end

    # @param [Occi::Core::Model] model
    # @return [Occi::Core::Model]
    def model=(model)
      @model = model

      @kinds.model = model
      @mixins.model = model
      @actions.model = model
      @resources.model = model
      @links.model = model

      @action.model = model if @action
    end

    # @param incl_categories [Boolean] check every category against the model
    # @param set_default_attrs [Boolean] set default attribute values for all entities
    # @return [Boolean] result
    def check(incl_categories = false, set_default_attrs = false)
      @resources.check(set_default_attrs)
      @links.check(set_default_attrs)
      @action.check(set_default_attrs) if @action

      if incl_categories
        @kinds.check
        @mixins.check
        @actions.check
      end

      true
    end

    # @param [Occi::Collection] other_collection
    # @return [Occi::Collection]
    def merge!(other_collection)
      self.kinds.merge other_collection.kinds.select { |kind| get_by_id(kind.type_identifier).nil? }
      self.mixins.merge other_collection.mixins.select { |mixin| get_by_id(mixin.type_identifier).nil? }
      self.actions.merge other_collection.actions.select { |action| get_by_id(action.type_identifier).nil? }
      self.resources.merge other_collection.resources.select { |resource| get_by_id(resource.id).nil? }
      self.links.merge other_collection.links.select { |link| get_by_id(link.id).nil? }
      self.action = other_collection.action if other_collection.action
    end

    # @param [Occi::Collection] other_collection
    # @param [Occi::Collection] collection
    # @return [Occi::Collection]
    def merge(other_collection, first=self)
      collection = Occi::Collection.new

      collection.merge!(first)
      collection.merge!(other_collection)

      collection
    end

    # @param [Occi::Collection] other_collection
    # @return [Occi::Collection]
    def intersect!(other_collection)
      intersect other_collection, self
    end

    # @param [Occi::Collection] other_collection
    # @param [Occi::Collection] collection
    # @return [Occi::Collection]
    def intersect(other_collection, collection=self.clone)
      collection.kinds.replace other_collection.kinds.select { |kind| get_by_id(kind.type_identifier) }
      collection.mixins.replace other_collection.mixins.select { |mixin| get_by_id(mixin.type_identifier) }
      collection.actions.replace other_collection.actions.select { |action| get_by_id(action.type_identifier) }
      collection.resources.replace other_collection.resources.select { |resource| get_by_id(resource.id) }
      collection.links.replace other_collection.links.select { |link| get_by_id(link.id) }

      if collection.action == other_collection.action
        collection.action = other_collection.action
      else
        collection.action = nil
      end

      collection
    end

    # Returns the category corresponding to a given id
    #
    # @param id [String] identifier
    # @param cats_only [Boolean] look only for categories
    # @return [Occi::Core::Category]
    def get_by_id(id, cats_only = false)
      raise "Cannot do a look-up with a blank id!" if id.blank?
      object = self.categories.select { |category| category.type_identifier == id }
      object = self.entities.select { |entity| entity.id == id } if !cats_only && object.empty?
      object.first
    end

    # Returns the category corresponding to a given location
    #
    # @param [String] location
    # @return [Occi::Core::Category]
    def get_by_location(location)
      raise "Cannot do a look-up with a blank location!" if location.blank?
      self.categories.select { |category| category.location == instance2cat(location) }.first
    end

    # @return [true,false] true if collection is empty, false otherwise
    def empty?
      @kinds.empty? && @mixins.empty? && @actions.empty? && @resources.empty? && @links.empty? && @action.nil?
    end

    # Returns a collection with all categories related to the specified category
    #
    # @param [Occi::Core::Category, String] category
    # @return [Occi::Core::Collection]
    def get_related_to(category)
      raise "Cannot do a look-up with a blank category!" if category.blank?
      collection = self.class.new
      collection.kinds = @kinds.get_related_to(category)
      collection.mixins = @mixins.get_related_to(category)
      collection
    end

    # @return [Hashie::Mash] json representation
    def as_json(options = {})
      return @action.as_json if standalone_action_instance?

      collection = Hashie::Mash.new
      collection.kinds = @kinds.collect { |kind| kind.as_json } if @kinds.any?
      collection.mixins = @mixins.collect { |mixin| mixin.as_json } if @mixins.any?
      collection.actions = @actions.collect { |action_category| action_category.as_json } if @actions.any?
      collection.resources = @resources.collect { |resource| resource.as_json } if @resources.any?

      # if there is only one resource and the links inside the resource have no location,
      # then these links must be rendered as separate links inside the collection
      if collection.resources && collection.resources.size == 1
        if collection.resources.first.links.blank? && @links.empty?
          lnks = @resources.first.links
        else
          lnks = @links
        end
      else
        lnks = @links
      end
      collection.links = lnks.collect { |link| link.as_json } if lnks.to_a.any?

      collection
    end

    # @return [String] text representation
    def to_text
      text = ""

      if standalone_links?
        raise "Only one standalone link allowed for rendering to text/plain!" if self.links.size > 1
        text << self.links.first.to_text
      elsif standalone_action_instance?
        text << self.action.to_text
      else
        text << self.categories.collect { |category| category.to_text }.join("\n")
        text << "\n" if self.categories.any?
        raise "Only one resource allowed for rendering to text/plain!" if self.resources.size > 1
        text << self.resources.first.to_text if self.resources.any?
        text << self.links.collect { |link| link.to_text_link }.join("\n")
        text << self.action.to_text if self.action
      end

      text
    end

    def to_header
      header = Hashie::Mash.new

      if standalone_links?
        raise "Only one standalone link allowed for rendering to text/occi!" if self.links.size > 1
        header = self.links.first.to_header
      elsif standalone_action_instance?
        header = self.action.to_header
      else
        header['Category'] = self.categories.collect { |category| category.to_string }.join(',') if self.categories.any?
        raise "Only one resource allowed for rendering to text/occi!" if self.resources.size > 1
        header = self.class.header_merge(header, self.resources.first.to_header) if self.resources.any?
        header['Link'] = self.links.collect { |link| link.to_string }.join(',') if self.links.any?
        header = self.class.header_merge(header, self.action.to_header) if self.action
      end

      header
    end

    private

    def self.header_merge(target, other, separator=',')
      other.each_pair do |key,val|
        if target.key?(key)
          target[key] = "#{target[key]}#{separator}#{val}"
        else
          target[key] = val
        end
      end
      target
    end

    def standalone_links?
      !self.links.blank? && self.categories.blank? && self.resources.blank? && self.action.blank?
    end

    def standalone_action_instance?
      !self.action.blank? && self.categories.blank? && self.entities.blank?
    end

    def instance2cat(location)
      return location if location.start_with?('/') && location.end_with?('/')
      cat_relative_uri = "#{File.dirname(URI.parse(location).path)}/"
      raise "Supplied location is invalid! #{cat_relative_uri.inspect}" unless cat_relative_uri =~ /\/.+\//
      cat_relative_uri
    end

  end
end
