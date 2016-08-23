module Occi
  module Core
    # Implements the base class for all OCCI resources, this
    # class can be used directly to create resource instances.
    #
    # @attr links [Set] set of links associated with this resource instance
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Resource < Entity
      attr_reader :links

      # @return [String] resource summary
      def summary
        self['occi.core.summary']
      end

      # @param summary [String] resource summary
      def summary=(summary)
        self['occi.core.summary'] = summary
      end

      # @param links [Set] set of links
      def links=(links)
        raise Occi::Core::Errors::InstanceValidationError,
              'Missing valid links' unless links
        @links = Set.new(links.collect { |link| link.source = self })

        links
      end

      def link_to(other)
        # TODO: implement after Occi::Core::Link
      end

      protected

      # :nodoc:
      def defaults
        super.merge(links: Set.new)
      end

      # :nodoc:
      def sufficient_args!(args)
        super
        raise Occi::Core::Errors::MandatoryArgumentError,
              "Links is a mandatory argument for #{self.class}" if args[:links].nil?
      end

      # :nodoc:
      def post_initialize(args)
        super
        self.links = args.fetch(:links)
      end
    end
  end
end
