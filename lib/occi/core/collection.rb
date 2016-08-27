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

      ALL_KEYS = [:categories, :entities, :action_instances].freeze

      attr_accessor(*ALL_KEYS)

      def initialize(args = {})
        pre_initialize(args)
        default_args! args

        ALL_KEYS.each { |key| instance_variable_set("@#{key}", args.fetch(key)) }

        post_initialize(args)
      end

      def all
        Set.new(ALL_KEYS.collect { |key| send(key).to_a }.flatten.compact)
      end

      def kinds
        typed_set(categories, Occi::Core::Kind)
      end

      def mixins
        typed_set(categories, Occi::Core::Mixin)
      end

      def actions
        typed_set(categories, Occi::Core::Action)
      end

      def resources
        typed_set(entities, Occi::Core::Resource)
      end

      def links
        typed_set(entities, Occi::Core::Link)
      end

      def find_by_location(location)
        raise ArgumentError, 'Location is a mandatory argument' if location.blank?
        Set.new(all.select { |elm| elm.respond_to?(:location) }.collect { |elm| elm.location == location })
      end

      def find_by_kind(kind)
        raise ArgumentError, 'Kind is a mandatory argument' unless kind
        raise ArgumentError, 'Kind must be an Occi::Core::Kind instance' unless kind.is_a?(Occi::Core::Kind)
        Set.new(entities.collect { |elm| elm.kind == kind })
      end

      def find_by_id(id)
        raise ArgumentError, 'ID is a mandatory argument' if id.blank?
        Set.new(entities.collect { |elm| elm.id == id })
      end

      def find_by_identifier(identifier)
        raise ArgumentError, 'Identifier is a mandatory argument' if identifier.blank?
        Set.new(categories.collect { |elm| elm.identifier == identifier })
      end

      def find_by_term(term)
        raise ArgumentError, 'Term is a mandatory argument' if term.blank?
        Set.new(categories.collect { |elm| elm.term == term })
      end

      def find_by_schema(schema)
        raise ArgumentError, 'Schema is a mandatory argument' if schema.blank?
        Set.new(categories.collect { |elm| elm.schema == schema })
      end

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

      def valid?
        all.collect(&:valid?).reduce(true, :&)
      end

      def valid!
        all.each(&:valid!)
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

      def typed_set(source, filter)
        Set.new(source.collect { |elm| elm.is_a?(filter) })
      end
    end
  end
end
