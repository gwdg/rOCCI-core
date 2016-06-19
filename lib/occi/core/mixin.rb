module Occi
  module Core
    # Defines the extension mechanism of the OCCI Core Model. The
    # `Mixin` instance can be used to add `actions`, `attributes`,
    # and custom features to existing `Entity` instances based on
    # a specific `Kind` instance. A `Mixin` instance may depend
    # on other `Mixin` instances (see `#depends`) and may be applied
    # only to `Entity` instances based on specified `Kind` instances
    # (see `#applies`). Some `Mixin` instances have special meaning
    # defined in OCCI Standard documents.
    #
    # @attr actions [Array] list of `Action` instances attached to this mixin instance
    # @attr depends [Array] list of `Mixin` instances on which this mixin depends
    # @attr applies [Array] list of `Kind` instances to which this mixin can be applied
    # @attr location [URI] protocol agnostic location of this mixin instance
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Mixin < Category
      attr_accessor :actions, :depends, :applies, :location

      # Checks whether the given mixin is in the dependency
      # chains of this instance. Checking for dependencies
      # is strictly flat (no transitivity is applied). One
      # `Mixin` instance may depend on multiple other instances.
      #
      # @param mixin [Mixin] candidate instance
      # @return [TrueClass, FalseClass] result
      def depends?(mixin)
        return false unless depends && mixin
        depends.include? mixin
      end

      # Checks whether the given kind is in the applies
      # set of this instance (i.e., this mixin can be applied
      # to an `Entity` instance of the given kind). Checking
      # for applicable kinds is strictly flat (no transitivity
      # is applied). One `Mixin` instance may be applied to
      # multiple kinds (`Entity` instances of the given kind).
      #
      # @param kind [Kind] candidate instance
      # @return [TrueClass, FalseClass] result
      def applies?(kind)
        return false unless applies && kind
        applies.include? kind
      end

      protected

      # :nodoc:
      def defaults
        category_defaults = super

        category_defaults[:actions] = []
        category_defaults[:depends] = []
        category_defaults[:applies] = []
        category_defaults[:location] = nil

        category_defaults
      end

      # :nodoc:
      def sufficient_args!(args)
        super
        [:actions, :depends, :applies].each do |attr|
          raise Occi::Core::Errors::MandatoryArgumentError, "#{attr} is a mandatory " \
                "argument for #{self.class}" if args[attr].nil?
        end
      end

      # :nodoc:
      def post_initialize(args)
        @actions = args.fetch(:actions)
        @depends = args.fetch(:depends)
        @applies = args.fetch(:applies)
        @location = args.fetch(:location)

        self.location ||= generate_location
      end

      private

      # Generates default location based on the already configured
      # `term` attribute. Fails if `term` is not present.
      #
      # @example
      #   mixin.term              # => 'compute'
      #   mixin.generate_location # => '/compute/'
      #
      # @return [String] generated location string
      def generate_location
        raise Occi::Core::Errors::MandatoryArgumentError,
              'Cannot generate default location without a `term`' if term.blank?
        URI.parse "/#{term}/"
      end
    end
  end
end
