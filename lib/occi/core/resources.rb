module Occi
  module Core
    class Resources < Occi::Core::Entities

      def create(*args)
        resource       = Occi::Core::Resource.new(*args)
        resource.model = @model if @model
        self << resource
        resource
      end

    end
  end
end
