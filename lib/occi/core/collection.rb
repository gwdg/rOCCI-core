module Occi
  module Core
    # Implements a generic envelope for all OCCI-related instances. This
    # class can be used directly for various reasons or, in a specific way,
    # as an ancestor for custom classes providing `Collection`-like functionality.
    # Its primary purpose is to provide a tool for working with multiple
    # sets of different instance types, aid with their transport and validation.
    #
    # @attr entities [Set] set of entities associated with this collection instance
    # @attr action_instances [Set] set of action instances associated with this collection instance
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Collection < Model
      ALL_KEYS = [:entities, :action_instances].freeze
      attr_accessor(*ALL_KEYS)

      # Collects everything present in this collection and merges it into
      # a single set. This will include categories, entities, and action instances.
      # The resulting set can be used, for example, in conjunction with the `<<`
      # operator to create an independent copy of the collection.
      #
      # @return [Set] content of this collection as a new `Set` instance
      def all
        super | entities | action_instances
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

      # Collects all categories and entities with the given location.
      # This method looks for an explicit/full match on the location.
      #
      # @param location [URI] expected location
      # @return [Set] set of results possibly containing a mix of instance types and categories
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

      # Auto-assigns the given object to the appropriate internal set.
      # Unknown objects will result in an `ArgumentError` error.
      #
      # @param object [Object] object to be assigned
      # @return [Occi::Core::Collection] self, for chaining purposes
      def <<(object)
        case object
        when Occi::Core::Entity
          entities << object
        when Occi::Core::ActionInstance
          action_instances << object
        else
          super
        end

        self
      end

      # Auto-removes the given object from the appropriate internal set.
      # Unknown objects will result in an `ArgumentError` error.
      #
      # @param object [Object] object to be removed
      # @return [Occi::Core::Collection] self, for chaining purposes
      def remove(object)
        case object
        when Occi::Core::Entity
          entities.delete object
        when Occi::Core::ActionInstance
          action_instances.delete object
        else
          super
        end

        self
      end

      # Triggers validation on the underlying `Model` instance. In addition,
      # validates all included entities and action instances against categories
      # defined in the collection. Only the existence of categories is checked, no
      # further checks are performed.
      #
      # See `#valid!` on `Model` for details.
      def valid!
        super
        valid_entities!
        valid_action_instances!
        entities.each(&:valid!)
        action_instances.each(&:valid!)
      end

      # Quietly validates the collection. This method does not raise exceptions with
      # detailed descriptions of detected problems.
      #
      # See `#valid!` for details.
      def valid?
        super && \
          valid_helper?(:valid_entities!) && \
          valid_helper?(:valid_action_instances!) && \
          entities.collect(&:valid?).reduce(true, :&) && \
          action_instances.collect(&:valid?).reduce(true, :&)
      end

      protected

      # :nodoc:
      def defaults
        super.merge(entities: Set.new, action_instances: Set.new)
      end

      # :nodoc:
      def sufficient_args!(args)
        super
        ALL_KEYS.each do |attr|
          next if args[attr]
          raise Occi::Core::Errors::MandatoryArgumentError, "#{attr} is a mandatory " \
                "argument for #{self.class}"
        end
      end

      # :nodoc:
      def post_initialize(args)
        super
        ALL_KEYS.each { |key| instance_variable_set("@#{key}", args.fetch(key)) }
      end

      private

      # :nodoc:
      def valid_helper?(method)
        begin
          send method
        rescue Occi::Core::Errors::InstanceValidationError => ex
          logger.warn "Instance invalid: #{ex.message}"
          return false
        end

        true
      end

      # :nodoc:
      def valid_entities!
        cached_kinds = kinds
        cached_mixins = mixins
        entities.each do |ent|
          unless cached_kinds.include?(ent.kind)
            raise Occi::Core::Errors::InstanceValidationError,
                  "Entity ID[#{ent.id}] contains undeclared " \
                  "kind #{ent.kind_identifier}"
          end
          valid_mixins!(ent, cached_mixins)
        end
      end

      # :nodoc:
      def valid_mixins!(ent, cached_mixins)
        ent.mixins.each do |mxn|
          next if cached_mixins.include?(mxn)
          raise Occi::Core::Errors::InstanceValidationError,
                "Entity ID[#{ent.id}] contains undeclared " \
                "mixin #{mxn.identifier}"
        end
      end

      # :nodoc:
      def valid_action_instances!
        cached_actions = actions
        action_instances.each do |ai|
          next if cached_actions.include?(ai.action)
          raise Occi::Core::Errors::InstanceValidationError,
                'Action instance contains undeclared ' \
                "action #{ai.action_identifier}"
        end
      end
    end
  end
end
