module Occi
  describe Collection do
    let(:collection){ collection = Occi::Collection.new }

    context 'initialization' do
      
      context 'with base objects' do
        before(:each) {
          collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
          collection.mixins << "http://example.com/occi/tags#my_mixin"
          collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
          collection.action = Occi::Core::ActionInstance.new
          collection.resources << Occi::Core::Resource.new
          collection.links << Occi::Core::Link.new
        }

        it 'calssifies kind correctly' do
          expect(collection.kinds.first).to be_kind_of Occi::Core::Kind
        end

        it 'calssifies mixin correctly' do
          expect(collection.mixins.first).to be_kind_of Occi::Core::Mixin
        end

        it 'calssifies action correctly' do
          expect(collection.actions.first).to be_kind_of Occi::Core::Action
        end

        it 'calssifies resource correctly' do
          expect(collection.resources.first).to be_kind_of Occi::Core::Resource
        end

        it 'calssifies link correctly' do
          expect(collection.links.first).to be_kind_of Occi::Core::Link
        end

        it 'calssifies action instance correctly' do
          expect(collection.action).to be_kind_of Occi::Core::ActionInstance
        end
      end
    end
      
    context '#model' do
      it 'registers a model' do
        expect(collection.model).to be_kind_of Occi::Model
      end
    end
      
    context '#resources' do
      it 'can create a new OCCI Resource' do
        collection.resources.create 'http://schemas.ogf.org/occi/core#resource'
        expect(collection.resources.first).to be_kind_of Occi::Core::Resource
      end
    end

    context '#check' do
      it 'checks against model without failure' do
        collection.resources.create 'http://schemas.ogf.org/occi/core#resource'
        expect{ collection.check }.to_not raise_error
      end
    end

    context '#get_related_to' do
      before(:each){
        collection.kinds << Occi::Core::Resource.kind
        collection.kinds << Occi::Core::Link.kind
      }
      it 'gets Entity as a related kind' do
        expect(collection.get_related_to(Occi::Core::Entity.kind)).to eql collection
      end

      it 'gets Resource as a related kind' do
        expect(collection.get_related_to(Occi::Core::Resource.kind).kinds.first).to eql Occi::Core::Resource.kind
      end

      it 'gets Link as a related kind' do
        expect(collection.get_related_to(Occi::Core::Link.kind).kinds.first).to eql Occi::Core::Link.kind
      end
    end

  end
end
