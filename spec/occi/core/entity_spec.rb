module Occi
  module Core
    describe Entity do

      it "initializes itself successfully" do
        entity = Occi::Core::Entity.new
        expect(entity).to be_kind_of Occi::Core::Entity
      end

      context 'initializiation of a subclass using a type identifier' do
        let(:type_identifier){ 'http://example.com/testnamespace#test' }
        let(:entity){ Occi::Core::Entity.new type_identifier }
        it 'has the correct kind' do
          expect(entity).to be_kind_of 'Com::Example::Testnamespace::Test'.constantize
        end
        it 'uses the right identifier' do
          expect(entity.kind.type_identifier).to eq type_identifier
        end
        it 'relates to Entity' do
          expect(entity.kind.related.first).to eq Occi::Core::Entity.kind
        end
      end

      context "initialization of a subclass using an OCCI Kind" do
        let(:kind){ Occi::Core::Resource.kind }
        let(:entity){ Occi::Core::Entity.new kind }
        it 'has the correct kind' do
          expect(entity).to be_kind_of Occi::Core::Resource
        end
        it 'uses the right identifier' do
          expect(entity.kind.type_identifier).to eq Occi::Core::Resource.type_identifier
        end
        it 'relates to Entity' do
          expect(entity.kind.related.first).to eq Occi::Core::Entity.kind
        end
      end

      it "converts mixin type identifiers to objects if a mixin is added to the entities mixins" do
        mixin = 'http://example.com/mynamespace#mymixin'
        entity = Occi::Core::Entity.new
        entity.mixins << mixin
        expect(entity.mixins.first.to_s).to eq mixin
      end

      # TODO: check adding of model
      context 'checking attribute validity' do
        let(:entity){ Occi::Core::Entity.new }
        it 'fails check with model missing' do
          expect { entity.check }.to raise_error
        end
        it 'runs check successfully with a model registered' do
          entity.model = Occi::Model.new
          entity.title = 'test'
          uuid = UUIDTools::UUID.random_create.to_s
          entity.id = uuid
          expect { entity.check }.to_not raise_error
        end
      end

    end
  end
end
