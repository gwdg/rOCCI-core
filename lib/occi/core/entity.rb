module Occi
  module Core
    # Implements the base class for all OCCI resources and links, this
    # class should be treated as an abstracts class and not used directly
    # to create entity instances.
    #
    # @attr kind [Occi::Core::Kind] entity kind, following OCCI's typing mechanism
    # @attr id [String] entity instance identifier, unique in the given domain
    # @attr location [URI] entity instance location, unique in the given domain
    # @attr title [String] entity instance title
    # @attr attributes [Hash] entity instance attributes
    # @attr mixins [Set] set of mixins associated with this entity instance
    # @attr actions [Set] set of actions associated with this entity instance
    #
    # @abstract The base class itself should be used as an abstract starting
    #           point when creating custom resources and links.
    # @author Boris Parak <parak@cesnet.cz>
    class Entity
      include Yell::Loggable
      include Helpers::Renderable
      include Helpers::Locatable
      include Helpers::InstanceAttributesAccessor
      include Helpers::ArgumentValidator
      include Helpers::InstanceAttributeResetter

      attr_accessor :kind, :actions, :attributes, :mixins
      attr_writer :location

      ERRORS = [
        Occi::Core::Errors::AttributeValidationError,
        Occi::Core::Errors::AttributeDefinitionError,
        Occi::Core::Errors::InstanceValidationError
      ].freeze

      # Constructs an instance with the given information. `kind` is a mandatory
      # argument, the rest will either default to appropriate values or remain
      # `nil`. The `id` attribute will default to a newly generated UUID, see
      # `SecureRandom.uuid` for details.
      #
      # @example
      #   my_kind = Occi::Core::Kind.new term: 'gnr', schema: 'http://example.org/test#'
      #   Entity.new kind: my_kind
      #
      # @param args [Hash] arguments with entity instance information
      # @option args [Occi::Core::Kind] :kind entity kind, following OCCI's typing mechanism
      # @option args [String] :id entity instance identifier, unique in the given domain
      # @option args [URI] :location entity instance location, unique in the given domain
      # @option args [String] :title entity instance title
      # @option args [Hash] :attributes entity instance attributes
      # @option args [Set] :mixins set of mixins associated with this entity instance
      # @option args [Set] :actions set of actions associated with this entity instance
      def initialize(args = {})
        pre_initialize(args)
        default_args! args

        @kind = args.fetch(:kind)
        @location = args.fetch(:location)
        @attributes = args.fetch(:attributes)
        @mixins = args.fetch(:mixins)
        @actions = args.fetch(:actions)

        post_initialize(args)
      end

      # @return [String] entity instance identifier, unique in the given domain
      def id
        self['occi.core.id']
      end

      # @param id [String] entity instance identifier, unique in the given domain
      def id=(id)
        self['occi.core.id'] = id
      end

      # @return [String] entity instance title
      def title
        self['occi.core.title']
      end

      # @param title [String] entity instance title
      def title=(title)
        self['occi.core.title'] = title
      end

      # Assigns new kind instance to this entity instance. This
      # method will trigger a complete reset on all previously
      # set attributes, for the sake of consistency.
      #
      # @param kind [Occi::Core::Kind] kind instance to be assigned
      # @return [Occi::Core::Kind] assigned kind instance
      def kind=(kind)
        raise Occi::Core::Errors::InstanceValidationError,
              'Missing valid kind' unless kind

        @kind = kind
        reset_attributes!

        kind
      end

      # Assigns new mixins instance to this entity instance. This
      # method will trigger a complete reset on all previously
      # set attributes, for the sake of consistency.
      #
      # @param kind [Hash] mixins instance to be assigned
      # @return [Hash] mixins instance assigned
      def mixins=(mixins)
        raise Occi::Core::Errors::InstanceValidationError,
              'Missing valid mixins' unless mixins

        @mixins = mixins
        reset_added_attributes!
        remove_undef_attributes
        # TODO: handle sync'ing actions

        mixins
      end

      # Shorthand for assigning mixins and actions to entity
      # instances. Unsupported `object` types will raise an
      # error. `self` is always returned for chaining purposes.
      #
      # @example
      #   entity << mixin   #=> #<Occi::Core::Entity>
      #   entity << action  #=> #<Occi::Core::Entity>
      #
      # @param object [Occi::Core::Mixin, Occi::Core::Action] object to be added
      # @return [Occi::Core::Entity] self
      def <<(object)
        case object
        when Occi::Core::Mixin
          add_mixin object
        when Occi::Core::Action
          add_action object
        else
          raise ArgumentError, "Cannot automatically assign #{object.inspect}"
        end

        self
      end
      alias add <<

      # Shorthand for removing mixins and actions from entity
      # instances. Unsupported `object` types will raise an
      # error. `self` is always returned for chaining purposes.
      #
      # @example
      #   entity.remove mixin   #=> #<Occi::Core::Entity>
      #   entity.remove action  #=> #<Occi::Core::Entity>
      #
      # @param object [Occi::Core::Mixin, Occi::Core::Action] object to be removed
      # @return [Occi::Core::Entity] self
      def remove(object)
        case object
        when Occi::Core::Mixin
          remove_mixin object
        when Occi::Core::Action
          remove_action object
        else
          raise ArgumentError, "Cannot automatically remove #{object.inspect}"
        end

        self
      end

      # Adds the given mixin to this instance. Attributes defined in the mixin
      # will be transfered to instance attributes.
      #
      # @param mixin [Occi::Core::Mixin] mixin to be added
      def add_mixin(mixin)
        raise Occi::Core::Errors::MandatoryArgumentError,
              'Cannot add a non-existent mixin' unless mixin

        # TODO: handle adding actions
        mixins << mixin
        reset_added_attributes
      end

      # Removes the given mixin from this instance. Attributes defined in the
      # mixin will be reset to their original definition or removed completely
      # if not defined as part of `kind` attributes.
      #
      # @param mixin [Occi::Core::Mixin] mixin to be removed
      def remove_mixin(mixin)
        raise Occi::Core::Errors::MandatoryArgumentError,
              'Cannot remove a non-existent mixin' unless mixin

        # TODO: handle removing actions
        mixins.delete mixin
        reset_attributes
      end

      # Replaces the given mixin in this instance with a new mixin provided.
      # This is a shorthand for invoking `remove_mixin` and `add_mixin`.
      #
      # @param old_mixin [Occi::Core::Mixin] mixin to be removed
      # @param new_mixin [Occi::Core::Mixin] mixin to be added
      def replace_mixin(old_mixin, new_mixin)
        # TODO: handle replacing actions
        remove_mixin old_mixin
        add_mixin new_mixin
      end

      # Adds the given action to this instance.
      #
      # @param action [Occi::Core::Action] action to be added
      def add_action(action)
        raise Occi::Core::Errors::MandatoryArgumentError,
              'Cannot add a non-existent action' unless action
        actions << action
      end

      # Removes the given action from this instance.
      #
      # @param action [Occi::Core::Action] action to be removed
      def remove_action(action)
        raise Occi::Core::Errors::MandatoryArgumentError,
              'Cannot remove a non-existent action' unless action
        actions.delete action
      end

      # Validates the content of this entity instance, including
      # all previously defined OCCI attributes and other required
      # elements. This method limits the information returned to
      # a boolean response.
      #
      # @example
      #   entity.valid? #=> false
      #   entity.valid? #=> true
      #
      # @return [TrueClass] when entity instance is valid
      # @return [FalseClass] when entity instance is invalid
      def valid?
        begin
          valid!
        rescue *ERRORS => ex
          logger.warn "Entity invalid: #{ex.message}"
          return false
        end

        true
      end

      # Validates the content of this entity instance, including
      # all previously defined OCCI attributes and other required
      # elements. This method provides additional information in
      # messages of raised errors.
      #
      # @example
      #   entity.valid! #=> #<Occi::Core::Errors::InstanceValidationError>
      #   entity.valid! #=> nil
      #
      # @return [NilClass] when entity instance is valid
      def valid!
        [:kind, :id, :location, :title, :attributes, :mixins, :actions].each do |attr|
          raise Occi::Core::Errors::InstanceValidationError,
                "Missing valid #{attr}" unless send(attr)
        end

        attributes.each_pair { |name, attribute| valid_attribute!(name, attribute) }
      end

      # Returns all base attributes for this instance in the
      # form of the original hash.
      #
      # @return [Hash] hash with base attributes
      def base_attributes
        kind.attributes
      end

      # Collects all available additional attributes for this
      # instance and returns them as an array.
      #
      # @return [Array] array with added attribute hashes
      def added_attributes
        mixins.collect(&:attributes)
      end

      protected

      # :nodoc:
      def valid_attribute!(name, attribute)
        attribute.valid!
      rescue => ex
        raise ex, "Attribute #{name.inspect} invalid: #{ex}", ex.backtrace
      end

      # :nodoc:
      def sufficient_args!(args)
        [:kind, :attributes, :mixins, :actions].each do |attr|
          raise Occi::Core::Errors::MandatoryArgumentError, "#{attr} is a mandatory " \
                "argument for #{self.class}" unless args[attr]
        end
      end

      # :nodoc:
      def defaults
        {
          kind: nil, id: SecureRandom.uuid, location: nil, title: nil,
          attributes: {}, mixins: Set.new, actions: Set.new
        }
      end

      # :nodoc:
      def pre_initialize(args); end

      # :nodoc:
      def post_initialize(args)
        reset_attributes

        self.id = args.fetch(:id) if attributes['occi.core.id']
        self.title = args.fetch(:title) if attributes['occi.core.title']
      end

      # Generates default location based on the already configured
      # `kind.location` and `id` attribute. Fails if `id` is not present.
      #
      # @example
      #   entity.generate_location # => #<URI::Generic /compute/1>
      #
      # @return [URI] generated location
      def generate_location
        raise Occi::Core::Errors::MandatoryArgumentError,
              'Cannot generate default location without an `id`' if id.blank?
        URI.parse "#{kind.location}#{id}"
      end
    end
  end
end
