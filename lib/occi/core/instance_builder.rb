module Occi
  module Core
    # Provides mechanisms for easy instantiation of various
    # Entity sub-types such as Resource or Link (and their sub-types).
    # Unknown sub-types will result in generic `Occi::Core::Resource`
    # and `Occi::Core::Link` instances.
    # Known (pre-defined) sub-types will be provided as instances of
    # unique classes inheriting from the abovementioned.
    #
    # @attr model [Occi::Core::Model] model filled with known category definitions
    #
    # @author Boris Parak <parak@cesnet.cz>
    class InstanceBuilder
      include Yell::Loggable
      include Helpers::ArgumentValidator

      attr_accessor :model

      # Constructs and instance of the InstanceBuilder. It can be used to quickly and easily get
      # get instances of various `Occi::Core::Entity` sub-types based on their kind identifier.
      #
      # @param args [Hash] constructor arguments
      # @option args [Occi::Core::Model] :model model filled with known category definitions
      def initialize(args = {})
        pre_initialize(args)
        default_args! args

        @model = args.fetch(:model)

        post_initialize(args)
      end

      # Constructs an instance based on the given category identifier. This method
      # can construct instances of Entity sub-types.
      #
      # @example
      #    build 'http://schemas.ogf.org/occi/core#resource'
      #      # => Occi::Core::Resource
      #
      # @param identifier [String] identifier of the category
      # @param args [Hash] hash for the instance constructor
      # @return [Object] constructed instance
      # @return [NilClass] if such an instance could not be constructed
      def build(identifier, args = {})
        logger.debug "Building instance of #{identifier.inspect} with #{args.inspect}"
        k_args = args_with_kind(identifier, args)
        klass(identifier, parent_klass(k_args[:kind])).new k_args
      end
      alias get build

      # Constructs an instance based on the given category identifier. This method
      # can construct instances of Resource sub-types.
      #
      # @example
      #    build_resource 'http://schemas.ogf.org/occi/core#resource' # => Occi::Core::Resource
      #
      # @param identifier [String] identifier of the category
      # @param args [Hash] hash for the instance constructor
      # @return [Object] constructed instance
      # @return [NilClass] if such an instance could not be constructed
      def build_resource(identifier, args = {})
        klass(identifier, Occi::Core::Resource).new args_with_kind(identifier, args)
      end

      # Constructs an instance based on the given category identifier. This method
      # can construct instances of Link sub-types.
      #
      # @example
      #    build_link 'http://schemas.ogf.org/occi/core#link' # => Occi::Core::Link
      #
      # @param identifier [String] identifier of the category
      # @param args [Hash] hash for the instance constructor
      # @return [Object] constructed instance
      # @return [NilClass] if such an instance could not be constructed
      def build_link(identifier, args = {})
        klass(identifier, Occi::Core::Link).new args_with_kind(identifier, args)
      end

      # Looks up the appropriate candidate class for the given identifier. If no class
      # is found in static tables, the last known ancestor is returned. For Core, this
      # method ALWAYS returns the last known ancestor given as `known_ancestor`, for
      # compatibility reasons.
      #
      # @param identifier [String] identifier of the category
      # @param known_ancestor [Class] expected ancestor
      # @return [Class] pre-defined class or given last ancestor
      def klass(identifier, known_ancestor)
        found_klass = self.class.klass_map[identifier]
        return known_ancestor unless found_klass

        unless found_klass.ancestors.include?(known_ancestor)
          raise Occi::Core::Errors::InstanceValidationError,
                "#{found_klass} is not a sub-type of #{known_ancestor}"
        end

        logger.debug "Found class #{found_klass} for #{identifier.inspect}"
        found_klass
      end

      # Looks up the given identifier in the model. Returns `Occi::Core::Kind` instance if
      # found and raises an error otherwise. Look-up results not related to `Occi::Core::Kind`
      # will also raise an error.
      #
      # @param identifier [String] identifier of the category
      # @return [Occi::Core::Kind] full category definition from the model
      def kind_instance(identifier)
        kind = model.find_by_identifier!(identifier)
        unless kind.is_a? Occi::Core::Kind
          raise Occi::Core::Errors::CategoryValidationError, "#{identifier.inspect} " \
                'is not a kind'
        end
        kind
      end

      # Locates the closes known parent class for instances of the given kind.
      # This usually means `Occi::Core::Resource`, `Occi::Core::Link`, or error.
      #
      # @param kind [Occi::Core::Kind] kind instance to evaluate
      # @return [Class] located known parent class
      def parent_klass(kind)
        if kind.related? kind_instance(Occi::Core::Constants::RESOURCE_KIND)
          logger.debug "Identified #{kind.identifier} as Resource"
          Occi::Core::Resource
        elsif kind.related? kind_instance(Occi::Core::Constants::LINK_KIND)
          logger.debug "Identified #{kind.identifier} as Link"
          Occi::Core::Link
        else
          raise Occi::Core::Errors::ModelLookupError,
                "Could not identify #{kind.identifier} as a Link or Resource"
        end
      end

      class << self
        # :nodoc:
        def klass_map
          {}
        end
      end

      protected

      # :nodoc:
      def sufficient_args!(args)
        return if args[:model]
        raise Occi::Core::Errors::MandatoryArgumentError, 'model is a mandatory ' \
              "argument for #{self.class}"
      end

      # :nodoc:
      def defaults
        { model: nil }
      end

      # :nodoc:
      def pre_initialize(args); end

      # :nodoc:
      def post_initialize(args); end

      # :nodoc:
      def args_with_kind(identifier, args)
        k_args = args.clone
        k_args[:kind] = kind_instance(identifier)
        k_args[:rel] = kind_instance(k_args[:rel]) if k_args[:rel]
        k_args
      end
    end
  end
end
