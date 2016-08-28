module Occi
  module Core
    # Implements the base class for all OCCI resources, this
    # class can be used directly to create resource instances.
    #
    # @attr links [Set] set of links associated with this resource instance
    # @attr summary [String] simple human-readable description of this resource instance
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
        links.each { |link| link.source = self }
        @links = links

        links
      end

      # :nodoc:
      def <<(object)
        case object
        when Occi::Core::Link
          add_link(object)
          return self
        end

        super
      end

      # :nodoc:
      def remove(object)
        case object
        when Occi::Core::Link
          remove_link(object)
          return self
        end

        super
      end

      # Adds the given link to this instance.
      #
      # @param link [Occi::Core::Link] link to be added
      def add_link(link)
        raise Occi::Core::Errors::MandatoryArgumentError,
              'Cannot add a non-existent link' unless link
        link.source = self
        links << link
      end

      # Removes the given link from this instance.
      #
      # @param link [Occi::Core::Link] link to be removed
      def remove_link(link)
        raise Occi::Core::Errors::MandatoryArgumentError,
              'Cannot remove a non-existent link' unless link
        link.source = nil
        links.delete link
      end

      # See `#valid!` on `Occi::Core::Entity`.
      def valid!
        # TODO: validate included links
        raise Occi::Core::Errors::InstanceValidationError,
              'Missing valid links' unless links
        super
      end

      protected

      # :nodoc:
      def defaults
        super.merge(links: Set.new, summary: nil)
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
        self.summary = args.fetch(:summary) if attributes['occi.core.summary']
      end
    end
  end
end
