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

      protected

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
      def post_initialize(args); end

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
