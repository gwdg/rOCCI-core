module Occi
  module Core
    # Implements a generic envelope for all OCCI-related instances. This
    # class can be used directly for various reasons or, in a specific way,
    # as an ancestor for custom classes providing `Model`-like functionality.
    # Its primary purpose is to provide a tool for working with multiple
    # sets of different instance types, aid with their transport and validation.
    #
    # @attr categories [Set]
    # @attr entities [Set]
    # @attr action_instances [Set]
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Collection
      include Yell::Loggable
      include Helpers::ArgumentValidator
      include Helpers::Renderable

      ALL_KEYS = [:categories, :entities, :action_instances].freeze

      attr_accessor(*ALL_KEYS)

      # Constructs an instance with the given information. All arguments are
      # optional and will default to empty `Set` instances if not provided.
      #
      # @example
      #   my_coll = Occi::Core::Collection.new
      #   my_coll << mixin << kind << entity
      #
      # @param args [Hash] arguments with collection instance information
      # @option args [Set] :categories set of categories associated with this collection instance
      # @option args [Set] :entities set of entities associated with this collection instance
      # @option args [Set] :action_instances set of action instances associated with this collection instance
      def initialize(args = {})
        pre_initialize(args)
        default_args! args

        ALL_KEYS.each { |key| instance_variable_set("@#{key}", args.fetch(key)) }

        post_initialize(args)
      end

      # Collects everything present in this collection and merges it into
      # a single set. This will include categories, entities, and action instances.
      # The resulting set can be used, for example, in conjunction with the `<<`
      # operator to create an independent copy of the collection.
      #
      # @return [Set] content of this collection merged into a single set
      def all
        Set.new(ALL_KEYS.collect { |key| send(key).to_a }.flatten.compact)
      end

      # Collects all `Occi::Core::Kind` instances in this collection.
      #
      # @return [Set] all `Occi::Core::Kind` instances from this collection
      def kinds
        typed_set(categories, Occi::Core::Kind)
      end

      # Collects all `Occi::Core::Mixin` instances in this collection.
      #
      # @return [Set] all `Occi::Core::Mixin` instances from this collection
      def mixins
        typed_set(categories, Occi::Core::Mixin)
      end

      # Collects all `Occi::Core::Action` instances in this collection.
      #
      # @return [Set] all `Occi::Core::Action` instances from this collection
      def actions
        typed_set(categories, Occi::Core::Action)
      end

      # Collects all `Occi::Core::Resource` instances in this collection.
      #
      # @return [Set] all `Occi::Core::Resource` instances from this collection
      def resources
        typed_set(entities, Occi::Core::Resource)
      end

      # Collects all `Occi::Core::Link` instances in this collection.
      #
      # @return [Set] all `Occi::Core::Link` instances from this collection
      def links
        typed_set(entities, Occi::Core::Link)
      end

      # Collects all `Occi::Core::Kind` instances related to the given instance.
      #
      # @param kind [Occi::Core::Kind] top-level kind
      # @param options [Hash] look-up modifiers, currently only `directly: true`
      # @return [Set] all instances related to the given instance
      def find_related(kind, options = { directly: false })
        raise ArgumentError, 'Kind is a mandatory argument' unless kind
        method = options[:directly] ? :directly_related? : :related?
        Set.new(kinds.select { |knd| knd.send(method, kind) })
      end

      # Collects all `Occi::Core::Mixin` instances dependent on the given instance.
      #
      # @param mixin [Occi::Core::Mixin] top-level mixin
      # @return [Set] all instances dependent on the given instance
      def find_dependent(mixin)
        raise ArgumentError, 'Mixin is a mandatory argument' unless mixin
        Set.new(mixins.select { |mxn| mxn.depends?(mixin) })
      end

      # Collects all categories and entities with the given location.
      # This method looks for an explicit/full match on the location.
      #
      # @param location [URI] expected location
      # @return [Set] set of results possibly containing a mix of instance types
      def find_by_location(location)
        filtered_set(
          all.select { |elm| elm.respond_to?(:location) },
          key: 'location', value: location
        )
      end

      # Collects all `Occi::Core::Entity` successors with the given
      # kind. The resulting set may contain mixed instance types.
      #
      # @param kind [Occi::Core::Kind] expected kind
      # @return [Set] set of entities with the given kind
      def find_by_kind(kind)
        raise ArgumentError, 'Kind is a mandatory argument' unless kind
        filtered_set(entities, key: 'kind', value: kind)
      end

      # Collects all `Occi::Core::ActionInstance` instances with the given action.
      #
      # @param action [Occi::Core::Action] expected action
      # @return [Set] set of found action instances
      def find_by_action(action)
        raise ArgumentError, 'Action is a mandatory argument' unless action
        filtered_set(action_instances, key: 'action', value: action)
      end

      # Collects all `Occi::Core::Entity` successors associated with the given mixin.
      #
      # @param mixin [Occi::Core::Mixin] expected mixin
      # @return [Set] set of found entities
      def find_by_mixin(mixin)
        raise ArgumentError, 'Mixin is a mandatory argument' unless mixin
        Set.new(entities.select { |elm| elm.mixins.include?(mixin) })
      end

      # Collects all `Occi::Core::Entity` successors with the given ID.
      #
      # @param id [String] expected ID
      # @return [Set] set of found entities
      def find_by_id(id)
        filtered_set(entities, key: 'id', value: id)
      end

      # Collects all `Occi::Core::Category` successors with the given identifier.
      #
      # @param identifier [String] expected identifier
      # @return [Set] set of found categories
      def find_by_identifier(identifier)
        filtered_set(categories, key: 'identifier', value: identifier)
      end

      # Collects all `Occi::Core::Category` successors with the given term.
      #
      # @param term [String] expected term
      # @return [Set] set of found categories
      def find_by_term(term)
        filtered_set(categories, key: 'term', value: term)
      end

      # Collects all `Occi::Core::Category` successors with the given schema.
      #
      # @param schema [String] expected schema
      # @return [Set] set of found categories
      def find_by_schema(schema)
        filtered_set(categories, key: 'schema', value: schema)
      end

      # Auto-assigns the given object to the appropriate internal set.
      # Unknown objects will result in an `ArgumentError` error.
      #
      # @param object [Object] object to be assigned
      # @return [Occi::Core::Collection] self, for chaining purposes
      def <<(object)
        case object
        when Occi::Core::Category
          categories << object
        when Occi::Core::Entity
          entities << object
        when Occi::Core::ActionInstance
          action_instances << object
        else
          raise ArgumentError, "Cannot automatically assign #{object.inspect}"
        end

        self
      end
      alias add <<

      # Auto-removes the given object from the appropriate internal set.
      # Unknown objects will result in an `ArgumentError` error.
      #
      # @param object [Object] object to be removed
      # @return [Occi::Core::Collection] self, for chaining purposes
      def remove(object)
        case object
        when Occi::Core::Category
          categories.delete object
        when Occi::Core::Entity
          entities.delete object
        when Occi::Core::ActionInstance
          action_instances.delete object
        else
          raise ArgumentError, "Cannot automatically delete #{object.inspect}"
        end

        self
      end

      # Validates entities and action instances stored in this collection.
      # Validity of each instance is considered independently. If you are
      # looking for a more aggressive version raising validation errors,
      # see `#valid!`.
      #
      # @return [TrueClass] on successful validation
      # @return [FalseClass] on failed validation
      def valid?
        entities.collect(&:valid?).reduce(true, :&) && action_instances.collect(&:valid?).reduce(true, :&)
      end

      # Validates entities and action instances stored in this collection.
      # Validity of each instance is considered independently. This method
      # will raise an error on the first invalid instance.
      def valid!
        entities.each(&:valid!)
        action_instances.each(&:valid!)
      end

      protected

      # :nodoc:
      def sufficient_args!(args)
        ALL_KEYS.each do |attr|
          raise Occi::Core::Errors::MandatoryArgumentError, "#{attr} is a mandatory " \
                "argument for #{self.class}" unless args[attr]
        end
      end

      # :nodoc:
      def defaults
        hash = {}
        ALL_KEYS.each { |key| hash[key] = Set.new }
        hash
      end

      # :nodoc:
      def pre_initialize(args); end

      # :nodoc:
      def post_initialize(args); end

      private

      # :nodoc:
      def typed_set(source, type)
        Set.new(source.select { |elm| elm.is_a?(type) })
      end

      # :nodoc:
      def filtered_set(source, filter)
        raise ArgumentError, 'Filtering key is a mandatory argument' if filter[:key].blank?
        Set.new(source.select { |elm| elm.send(filter[:key]) == filter[:value] })
      end
    end
  end
end
