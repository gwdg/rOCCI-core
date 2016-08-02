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
      include Helpers::AttributesAccessor
      include Helpers::ArgumentValidator

      attr_accessor :kind, :id, :location, :title, :attributes, :mixins, :actions

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
        @id = args.fetch(:id)
        @location = args.fetch(:location)
        @title = args.fetch(:title)
        @attributes = args.fetch(:attributes)
        @mixins = args.fetch(:mixins)
        @actions = args.fetch(:actions)

        post_initialize(args)
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
        default_attrs!

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
        default_attrs!

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
          mixins << object
          default_attrs
        when Occi::Core::Action
          actions << object
        else
          raise ArgumentError, "Cannot automatically assign #{object.inspect}"
        end

        self
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
      #   entity.valid! #=> #<Occi::Core::Errors::EntityValidationError>
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
          kind: nil,
          id: SecureRandom.uuid,
          location: nil,
          title: nil,
          attributes: {},
          mixins: Set.new,
          actions: Set.new
        }
      end

      # :nodoc:
      def pre_initialize(args); end

      # :nodoc:
      def post_initialize(_args)
        default_attrs
      end

      # Shorthand for running `default_attrs` with the `force` flag on.
      # This method will force defaults from definitions in all available
      # attributes.
      def default_attrs!
        default_attrs true
      end

      # Iterates over available attribute definitions (in `kind` and `mixins`) and
      # sets corresponding fields in `attributes`. When using the `force` flag, all
      # existing attribute values will be replaced by defaults from definitions or
      # reset to `nil`.
      #
      # @param force [TrueClass, FalseClass] forcibly change attribute values to defaults
      def default_attrs(force = false)
        kind.attributes.each_pair { |name, definition| default_attr(name, definition, force) }

        mixins.each do |mixin|
          mixin.attributes.each_pair { |name, definition| default_attr(name, definition, force) }
        end
      end

      # Sets corresponding attribute fields in `attributes`. When using the `force` flag, any
      # existing attribute value will be replaced by the default from its definition or
      # reset to `nil`.
      #
      # @param name [String] attribute name
      # @param definition [AttributeDefinition] attribute definition
      # @param force [TrueClass, FalseClass] forcibly change attribute value to default
      def default_attr(name, definition, force)
        if attributes[name]
          attributes[name].attribute_definition = definition
        else
          attributes[name] = Attribute.new(nil, definition)
        end

        force ? attributes[name].default! : attributes[name].default
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
