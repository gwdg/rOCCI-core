module Occi
  module Core
    describe Categories do

      it "replaces an existing category instance when a model is added with the instance from the model"  do
        categories = Occi::Core::Categories.new
        categories << Occi::Core::Resource.kind
        model = Occi::Model.new
        resource = model.get_by_id Occi::Core::Resource.type_identifier
        resource.location = '/new_location/'
        categories.model = model
        expect(categories.first.location).to eq '/new_location/'
      end

      it "replaces a category string when a model is added with the instance from the model"  do
        categories = Occi::Core::Categories.new
        model = Occi::Model.new
        categories.model = model
        categories << Occi::Core::Resource.type_identifier

        resource = model.get_by_id Occi::Core::Resource.type_identifier
        resource.location = '/new_location/'
        expect(categories.first.location).to eq '/new_location/'
      end

    end
  end
end
