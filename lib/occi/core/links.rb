module Occi
  module Core
    class Links < Occi::Core::Entities

      def initialize(links=[])
        links.collect! {|link| convert link} if links
        super links
      end

      def <<(link)
        super convert link
      end

      def create(*args)
        link       = Occi::Core::Link.new(*args)
        link.model = @model if @model
        self << link

        link
      end

      private

      def convert(link)
        if link.kind_of? String
          link_location = link
          link = Occi::Core::Link.new
          link.id = link_location.split('/').last
          link.location = link_location
        end

        link
      end

    end
  end
end
