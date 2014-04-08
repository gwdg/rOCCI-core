module Occi
  module Core
    describe Entities do
      let(:entities){ Occi::Core::Entities.new }
      let(:entity1){ entity1 = Occi::Core::Entity.new
        entity1.id = "e1testid"
        entity1 }
      let(:entity2){ entity2 = Occi::Core::Entity.new 'http://example.org/test/schema#entity2'
        entity2.id = "e2testid"
        entity2 }
      let(:testaction){ Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action' }

      context 'populating' do

        it 'is created empty' do
          expect(entities.count).to eq 0
        end

        it 'gets entity Nos. right, 1' do
          entities << entity1
          expect(entities.count).to eq 1
        end

        it 'gets entity Nos. right, 2' do
          entities << entity1
          entities << entity2
          expect(entities.count).to eq 2
        end

        it 'gets correctly-typed elements' do
          entities << entity1
          entities << entity2
          expect(entities.first).to be_an_instance_of(Occi::Core::Entity)
        end

      end

      context '#model' do

        it 'has no model by default' do
          expect(entities.model).to be nil
        end

        it 'can be assigned model' do
          modl = Occi::Model.new
          entities.model = modl
          expect(entities.model).to eql modl
        end

        it 'uses the assigned model for new members' do
          modl = Occi::Model.new
          entities.model = modl
          entities << entity1
          expect(entities.first.model).to eql modl
        end

        it 'uses the assigned model for existing members' do
          entities << entity1
          modl = Occi::Model.new
          entities.model = modl
          expect(entities.first.model).to eql modl
        end

        it 'does not use unassigned model' do
          modl = Occi::Model.new
          entities << entity1
          expect(entities.first.model).to_not eql modl
        end

      end

      context '#create' do

        it 'creates a new element' do
          entities.create
          expect(entities.first).to be_instance_of(Occi::Core::Entity)
        end

        it 'accepts argument' do
          entities.create 'http://example.com/testnamespace#test'
          expect(entities.first).to be_kind_of 'Com::Example::Testnamespace::Test'.constantize
        end

      end

      context '#join' do

        it 'joins elements correctly' do
          entities << entity1
          entities << entity2
          expect(entities.join('|')).to eq '/entity/e1testid|/entity2/e2testid'
        end

      end

      context '#as_json' do

        it 'renders elements with various attributes' do
          entity2.actions << testaction
          entities << entity1
          entities << entity2
          expected = []
          hash=Hashie::Mash.new JSON.parse('{"kind":"http://schemas.ogf.org/occi/core#entity","attributes":{"occi":{"core":{"id":"e1testid"}}},"id":"e1testid"}')
          hash2= Hashie::Mash.new JSON.parse('{"kind":"http://example.org/test/schema#entity2","actions":["http://schemas.ogf.org/occi/core/entity/action#testaction"],"attributes":{"occi":{"core":{"id":"e2testid"}}},"id":"e2testid"}')
          expected << hash
          expected << hash2
          expect(entities.as_json).to eql expected
        end

      end

      context '#check' do

        let(:attr_w_defaults) do
          { :type => 'string',
            :pattern => '[adefltuv]+',
            :default => 'defaultvalue',
            :mutable => true }
        end
        let(:model) do
          model = Occi::Model.new
          model.kinds.first.attributes['string_attribute'] = attr_w_defaults
          model
        end
        let(:entities_w_defaults) do
          entities << Occi::Core::Entity.new
          entities.model = model
          entities
        end
        let(:entities_w_wrong_attrs) do
          ent1 = Occi::Core::Entity.new
          ent1.attributes['fake.attr.here'] = 1
          entities << ent1
          entities.model = model
          entities
        end

        it 'raises an error on undeclared attributes' do
          expect { entities_w_wrong_attrs.check }.to raise_error
        end

        it 'passes on an empty collection' do
          expect { entities.check }.not_to raise_error
          expect { entities.check(true) }.not_to raise_error
        end

        it 'does not set attribute defaults by default' do
          entities_w_defaults.check
          expect(entities_w_defaults.first.attributes['string_attribute']).to be_blank
        end

        it 'sets attributes default when requested' do
          entities_w_defaults.check(true)
          expect(entities_w_defaults.first.attributes['string_attribute']).to eq 'defaultvalue'
        end

      end
    end
  end
end
