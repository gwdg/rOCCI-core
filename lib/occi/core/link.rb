module Occi
  module Core
    # Implements the base class for all OCCI links, this
    # class can be used directly to create link instances.
    #
    # @attr source [URI] link source as URI
    # @attr target [URI] link target, may point outside of this domain
    # @attr rel [Occi::Core::Kind, NilClass] Kind of the `target` or `nil` if ourside the domain
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Link < Entity
      attr_accessor :rel

      # @return [URI] link source
      def source
        self['occi.core.source']
      end

      # @param source [URI] link source
      def source=(source)
        self['occi.core.source'] = source
      end

      # @return [URI] link target
      def target
        self['occi.core.target']
      end

      # @param target [URI] link target
      def target=(target)
        self['occi.core.target'] = target
      end

      # See `#valid!` on `Occi::Core::Entity`.
      def valid!
        %i[source target].each do |attr|
          unless send(attr)
            raise Occi::Core::Errors::InstanceValidationError,
                  "Missing valid #{attr}"
          end
        end

        super
      end

      protected

      # :nodoc:
      def defaults
        super.merge(source: nil, target: nil, rel: nil)
      end

      # :nodoc:
      def post_initialize(args)
        super
        self.source = args.fetch(:source) if attributes['occi.core.source']
        self.target = args.fetch(:target) if attributes['occi.core.target']
        @rel = args.fetch(:rel)
      end
    end
  end
end
