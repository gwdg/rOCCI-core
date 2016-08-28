module Occi
  module Core
    # Implements the base class for all OCCI links, this
    # class can be used directly to create link instances.
    #
    # @attr source [Occi::Core::Resource] link source, always a valid `Resource` instance
    # @attr target [Occi::Core::Resource, String] link target, may point outside of this domain
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Link < Entity
      # @return [Occi::Core::Resource] link source
      def source
        self['occi.core.source']
      end

      # @param source [Occi::Core::Resource] link source
      def source=(source)
        self['occi.core.source'] = source
      end

      # @return [Occi::Core::Resource, String] link target
      def target
        self['occi.core.target']
      end

      # @param target [Occi::Core::Resource, String] link target
      def target=(target)
        self['occi.core.target'] = target
      end

      # @return [Occi::Core::Kind] type of the target
      # @return [NilClass] target outside of the domain
      def rel
        target.respond_to?(:kind) ? target.kind : nil
      end

      # See `#valid!` on `Occi::Core::Entity`.
      def valid!
        [:source, :target].each do |attr|
          raise Occi::Core::Errors::InstanceValidationError,
                "Missing valid #{attr}" unless send(attr)
        end

        super
      end

      protected

      # :nodoc:
      def defaults
        super.merge(source: nil, target: nil)
      end

      # :nodoc:
      def post_initialize(args)
        super
        self.source = args.fetch(:source) if attributes['occi.core.source']
        self.target = args.fetch(:target) if attributes['occi.core.target']
      end
    end
  end
end
