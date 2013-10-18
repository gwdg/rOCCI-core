module Occi
  module Core
    describe Entity do
      let(:entity){ Occi::Core::Entity.new }
      let(:testaction){ Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action' }

      it "initializes itself successfully" do
        expect(entity).to be_kind_of Occi::Core::Entity
      end

      context 'initializiation of a subclass using a type identifier' do
        let(:type_identifier){ 'http://example.com/testnamespace#test' }
        let(:typed_entity){ Occi::Core::Entity.new type_identifier }
        it 'has the correct kind' do
          expect(typed_entity).to be_kind_of 'Com::Example::Testnamespace::Test'.constantize
        end
        it 'uses the right identifier' do
          expect(typed_entity.kind.type_identifier).to eq type_identifier
        end
        it 'relates to Entity' do
          expect(typed_entity.kind.related.first).to eq Occi::Core::Entity.kind
        end
      end

      context "initialization of a subclass using an OCCI Kind" do
        let(:kind){ Occi::Core::Resource.kind }
        let(:kind_entity){ Occi::Core::Entity.new kind }
        it 'has the correct kind' do
          expect(kind_entity).to be_kind_of Occi::Core::Resource
        end
        it 'uses the right identifier' do
          expect(kind_entity.kind.type_identifier).to eq Occi::Core::Resource.type_identifier
        end
        it 'relates to Entity' do
          expect(kind_entity.kind.related.first).to eq Occi::Core::Entity.kind
        end
      end

      it "converts mixin type identifiers to objects if a mixin is added to the entities mixins" do
        mixin = 'http://example.com/mynamespace#mymixin'
        entity.mixins << mixin
        expect(entity.mixins.first.to_s).to eq mixin
      end

      # TODO: check adding of model
      context 'checking attribute validity' do
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

      context 'attributes' do
        context '#location' do
          it 'can be set and read' do
            entity.location = 'TestLoc'
            expect(entity.location).to eq 'TestLoc'
          end
          it 'can be constructed from id' do
            entity.id = UUIDTools::UUID.random_create.to_s
            expect(entity.location).to eq '/entity/' + entity.id
          end
          it 'rejects non-matching values' #do
#            entity.model = Occi::Model.new
#            entity.location = ''
#            expect{entity.check}.to raise_error(Occi::Errors::AttributeTypeError)
#          end
        end
        context '#title' do
          it 'can be set and read' do
            entity.title = 'TestTitle'
            expect(entity.title).to eq 'TestTitle'
          end
          it 'rejects non-matching values' #do
#            entity.model = Occi::Model.new
#            entity.title = ''
#            expect{entity.check}.to raise_error(Occi::Errors::AttributeTypeError)
#          end
        end

        context '#actions' do
          it 'can be populated through redirection' do
            entity.actions << testaction
            expect(entity.actions.count).to eq 1
          end
          it 'can be assigned through the setter method' do
            acts = Occi::Core::Actions.new
            acts << testaction
            entity.actions=acts
            expect(entity.actions.count).to eq 1
          end
        end
      end

      context '#to_text' do
        it 'renders fresh instance in text correctly' do
          expected = ('Category: entity;scheme="http://schemas.ogf.org/occi/core#";class="kind"').split(/;/)
          actual = entity.to_text.split(/;/)
          expect(actual).to match_array(expected)
        end
        it 'renders instance with attributes in text correctly' #do
#          entity.actions << testaction
#          entity.title = 'TestTitle'
#          entity.location = 'TestLoc'
#          expected = ('Category: entity;scheme="http://schemas.ogf.org/occi/core#";class="kind"').split(/;/) # TODO: empty instance. Expand!
#          actual = entity.to_text.split(/;/)
#          expect(actual).to match_array(expected)
#        end
      end

      context '#to_header' do
        it 'renders fresh instance in HTML Header correctly' do
          hash=Hashie::Mash.new
          hash['Category']='entity;scheme="http://schemas.ogf.org/occi/core#";class="kind"'
          expect(entity.to_header).to eql(hash)
        end
        it 'renders instance with attributes in HTML Header correctly' #do
#          entity.actions << testaction
#          entity.title = 'TestTitle'
#          entity.location = 'TestLoc'
#          hash=Hashie::Mash.new
#          hash['Category']='entity;scheme="http://schemas.ogf.org/occi/core#";class="kind"'
#          expect(entity.to_header).to eql(hash)
#        end
      end

    end
  end
end
