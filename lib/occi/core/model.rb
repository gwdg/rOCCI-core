module Occi
  module Core
    # Implements a generic envelope for all OCCI-related categories. This
    # class can be used directly for various reasons or, in a specific way,
    # as an ancestor for custom classes providing `Model`-like functionality.
    # Its primary purpose is to provide a tool for working with multiple
    # sets of different categories, aid with their transport and validation.
    #
    # @attr categories [Set] set of categories associated with this model instance
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Model
      include Yell::Loggable
      include Helpers::ArgumentValidator
      include Helpers::Renderable

      attr_accessor :categories

      # Constructs an instance with the given information. All arguments are
      # optional and will default to empty `Set` instances if not provided.
      #
      # @example
      #   my_model = Occi::Core::Model.new
      #   my_model << mixin << kind << action
      #
      # @param args [Hash] arguments with model instance information
      # @option args [Set] :categories set of categories associated with this model instance
      def initialize(args = {})
        pre_initialize(args)
        default_args! args

        @categories = args.fetch(:categories)

        post_initialize(args)
      end

      # Collects everything present in this model and merges it into
      # a single set. This will include kinds, mixins, and actions.
      # The resulting set can be used, for example, in conjunction with the `<<`
      # operator to create an independent copy of the model.
      #
      # @return [Set] content of this model as a new `Set` instance
      def all
        Set.new categories
      end

      # Collects all `Occi::Core::Kind` instances in this model.
      #
      # @return [Set] all `Occi::Core::Kind` instances from this model
      def kinds
        typed_set(categories, Occi::Core::Kind)
      end

      # Collects all `Occi::Core::Mixin` instances in this model.
      #
      # @return [Set] all `Occi::Core::Mixin` instances from this model
      def mixins
        typed_set(categories, Occi::Core::Mixin)
      end

      # Collects all `Occi::Core::Action` instances in this model.
      #
      # @return [Set] all `Occi::Core::Action` instances from this model
      def actions
        typed_set(categories, Occi::Core::Action)
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

      # Collects all categories with the given location.
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
      # @return [Occi::Core::Model] self, for chaining purposes
      def <<(object)
        case object
        when Occi::Core::Category
          categories << object
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
      # @return [Occi::Core::Model] self, for chaining purposes
      def remove(object)
        case object
        when Occi::Core::Category
          categories.delete object
        else
          raise ArgumentError, "Cannot automatically delete #{object.inspect}"
        end

        self
      end

      # Validates kinds, mixins, and actions stored in this model.
      # Validity of each category is considered with regard to other categories.
      # If you are looking for a more aggressive version raising validation errors,
      # see `#valid!`.
      #
      # @return [TrueClass] on successful validation
      # @return [FalseClass] on failed validation
      def valid?
        # TODO: meh
        true
      end

      # Validates kinds, mixins, and actions stored in this model.
      # Validity of each category is considered with regard to other categories.
      # This method will raise an error on the first invalid instance.
      def valid!
        # TODO: meh
      end

      protected

      # :nodoc:
      def sufficient_args!(args)
        return if args[:categories]
        raise Occi::Core::Errors::MandatoryArgumentError, '`categories` is a mandatory ' \
              "argument for #{self.class}"
      end

      # :nodoc:
      def defaults
        { categories: Set.new }
      end

      # :nodoc:
      def pre_initialize(args); end

      # :nodoc:
      def post_initialize(args); end

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
