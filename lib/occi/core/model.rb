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

      # Collects all `Occi::Core::Kind` instances specified
      # as `parent` in one or more other kinds in this model.
      # These instances may not appear in the model itself if
      # it has not been successfully validated yet.
      #
      # @return [Set] parenting `Occi::Core::Kind` instances from this model
      def parent_kinds
        parents = kinds
        parents.collect!(&:parent)
        parents.reject!(&:nil?)
        parents
      end

      # Collects all `Occi::Core::Mixin` instances in this model.
      #
      # @return [Set] all `Occi::Core::Mixin` instances from this model
      def mixins
        typed_set(categories, Occi::Core::Mixin)
      end

      # Collects all `Occi::Core::Mixin` instances specified
      # in `depends` in one or more other mixins in this model.
      # These instances may not appear in the model itself if
      # it has not been successfully validated yet.
      #
      # @return [Set] depended on `Occi::Core::Mixin` instances from this model
      def depended_on_mixins
        depended_on = mixins
        depended_on.collect!(&:depends)
        depended_on.flatten!
        depended_on.reject!(&:nil?)
        depended_on
      end

      # Collects all `Occi::Core::Action` instances in this model.
      #
      # @return [Set] all `Occi::Core::Action` instances from this model
      def actions
        typed_set(categories, Occi::Core::Action)
      end

      # Collects all `Occi::Core::Action` instances specified
      # in `actions` in one or more other mixins/kinds in this model.
      # These instances may not appear in the model itself if
      # it has not been successfully validated yet.
      #
      # @return [Set] associated `Occi::Core::Action` instances from this model
      def associated_actions
        associated = kinds + mixins
        associated.collect!(&:actions)
        associated.flatten!
        associated.reject!(&:nil?)
        associated
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

      # Collects everything with the given location.
      # This method looks for an explicit/full match on the location.
      #
      # @param location [URI] expected location
      # @return [Set] set of results possibly containing a mix of types
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

      # See `find_by_identifier`. Returns first found object or raises an error.
      #
      # @param identifier [String] expected identifier
      # @return [Object] found category
      def find_by_identifier!(identifier)
        found = categories.detect { |elm| elm.identifier == identifier }
        raise Occi::Core::Errors::ModelLookupError, "Category #{identifier.inspect} not found in the model" unless found
        found
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
        valid_helper? :valid!
      end

      # Validates kinds, mixins, and actions stored in this model.
      # Validity of each category is considered with regard to other categories.
      # This method will raise an error on the first invalid instance.
      def valid!
        valid_categories! # checking all identifiers
        valid_parents!    # parentage on kinds
        valid_actions!    # associated actions
        valid_depends!    # dependencies on mixins
        valid_applies!    # applicability on mixins
      end

      # Reports emptiness of the model.
      #
      # @return [TrueClass] if there are no categories
      # @return [FalseClass] if there are some categories
      def empty?
        categories.empty?
      end
      alias nothing? empty?

      # Loads OGF's OCCI Core Standard from `Occi::Core::Warehouse`.
      #
      # @example
      #    model = Occi::Core::Model.new
      #    model.load_core!
      def load_core!
        logger.debug 'Loading Core definitions from Core::Warehouse'
        Occi::Core::Warehouse.bootstrap! self
      end

      # Returns an instance of `Occi::Core::InstanceBuilder` associated with this model.
      #
      # @return [Occi::Core::InstanceBuilder] instance of IB
      def instance_builder
        Occi::Core::InstanceBuilder.new(model: self)
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

      # :nodoc:
      def valid_helper?(method)
        begin
          send method
        rescue Occi::Core::Errors::InstanceValidationError => ex
          logger.warn "Instance invalid: #{ex.message}"
          return false
        rescue URI::InvalidURIError, Occi::Core::Errors::CategoryValidationError => ex
          logger.warn "Category invalid: #{ex.message}"
          return false
        end

        true
      end

      # :nodoc:
      def valid_categories!
        categories.each(&:valid!)
      end

      # :nodoc:
      def valid_parents!
        report_diff!('kinds') { parent_kinds - kinds }
      end

      # :nodoc:
      def valid_depends!
        report_diff!('mixins') { depended_on_mixins - mixins }
      end

      # :nodoc:
      def valid_applies!
        not_applicable = mixins.select { |mxn| mxn.applies.blank? }
        return if not_applicable.empty?
        logger.warn 'The following mixins are not applicable to any entity sub-type: ' \
                    "#{not_applicable.collect(&:identifier).inspect}"
      end

      # :nodoc:
      def valid_actions!
        report_diff!('actions') { associated_actions - actions }
      end

      # :nodoc:
      def report_diff!(type)
        raise 'You have to provide a diff block!' unless block_given?
        diff = yield
        return if diff.empty?

        raise Occi::Core::Errors::CategoryValidationError,
              "The following #{type} have been referenced but not defined: " \
              "#{diff.to_a.collect(&:identifier).inspect}"
      end
    end
  end
end
