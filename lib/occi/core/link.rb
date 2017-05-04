module Occi
  module Core
    # Implements the base class for all OCCI links, this
    # class can be used directly to create link instances.
    #
    # @attr source [URI] link source as URI
    # @attr source_kind [Occi::Core::Kind, NilClass] source kind or `nil` if unknown
    # @attr target [URI] link target, may point outside of this domain
    # @attr target_kind [Occi::Core::Kind, NilClass] target kind or `nil` if ourside the domain
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Link < Entity
      attr_accessor :target_kind, :source_kind

      # @return [URI] link source
      def source
        self['occi.core.source']
      end

      # @param source [URI] link source
      def source=(source)
        self['occi.core.source'] = source.is_a?(String) ? URI.parse(source) : source
      end

      # @return [URI] link target
      def target
        self['occi.core.target']
      end

      # @param target [URI] link target
      def target=(target)
        self['occi.core.target'] = target.is_a?(String) ? URI.parse(target) : target
      end

      # See `target_kind`
      alias rel target_kind
      alias rel= target_kind=

      # See `#valid!` on `Occi::Core::Entity`.
      def valid!
        %i[source target].each do |attr|
          next if send(attr)
          raise Occi::Core::Errors::InstanceValidationError, "Missing valid #{attr}"
        end

        super
      end

      protected

      # :nodoc:
      def defaults
        super.merge(source: nil, target: nil, target_kind: nil, source_kind: nil)
      end

      # :nodoc:
      def post_initialize(args)
        super
        if attributes['occi.core.source']
          self.source = args.fetch(:source)
          @source_kind = args.fetch(:source_kind)
        end

        return unless attributes['occi.core.target']
        self.target = args.fetch(:target)
        @target_kind = args.fetch(:target_kind)
      end
    end
  end
end
