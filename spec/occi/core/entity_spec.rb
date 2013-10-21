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

      context '#kind' do
        it 'accepts kind through assignment' #do
#          entity.kind = 'http://example.com/testnamespace#test'
#          debugger
#          expect(entity).to be_kind_of 'Com::Example::Testnamespace::Test'.constantize
#        end
      end

      context '#mixins' do
        let(:mixin){ 'http://example.com/mynamespace#mymixin' }   

        it "converts mixin type identifiers to objects if a mixin is added to the entities mixins" do
          entity.mixins << mixin
          expect(entity.mixins.first.to_s).to eq mixin
        end
      end

      context 'attributes' do

        context 'checking attribute validity' do
          before(:each) { Occi::Settings['compatibility']=false }
          after(:each) { Occi::Settings.reload! }

          it 'fails check with model missing' do
            expect { entity.check }.to raise_error
          end

          it 'runs check successfully with a model registered' do
            entity.model = Occi::Model.new
            entity.title = 'test'
            uuid = UUIDTools::UUID.random_create.to_s
            Occi::Settings['verify_attribute_pattern']=true
            expect { entity.id = uuid }.to_not raise_error
          end

          it 'rejects values not matching pattern' do
            entity.model = Occi::Model.new
            entity.id = 'id with spaces'
            Occi::Settings['verify_attribute_pattern']=true
            expect{ entity.id = 'id with spaces' }.to raise_error Occi::Errors::AttributeTypeError
          end
          
        end
        
        context '#location' do
          it 'can be set and read' do
            entity.location = 'TestLoc'
            expect(entity.location).to eq 'TestLoc'
          end

          it 'can be constructed from id' do
            entity.id = UUIDTools::UUID.random_create.to_s
            expect(entity.location).to eq '/entity/' + entity.id
          end
        end

        context '#title' do
          it 'can be set and read' do
            entity.title = 'TestTitle'
            expect(entity.title).to eq 'TestTitle'
          end
        end
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

      context '#to_text' do
        it 'renders fresh instance in text correctly' do
          expected = 'Category: entity;scheme="http://schemas.ogf.org/occi/core#";class="kind"'
          expect(entity.to_text).to eq(expected)
        end

        it 'renders instance with attributes in text correctly' do
          entity.actions << testaction
          entity.title = 'TestTitle'
          entity.location = '/TestLoc/1'
          entity.mixins <<  'http://example.com/mynamespace#mymixin'

          expected = %Q|Category: entity;scheme="http://schemas.ogf.org/occi/core#";class="kind"
Category: mymixin;scheme="http://example.com/mynamespace#";class="mixin"
X-OCCI-Attribute: occi.core.title="TestTitle"
Link: </TestLoc/1?action=testaction>;rel=http://schemas.ogf.org/occi/core/entity/action#testaction|
          expect(entity.to_text).to eq(expected)
        end
      end

      context '#to_header' do
        it 'renders fresh instance in HTTP Header correctly' do
          expected = Hashie::Mash.new
          expected['Category'] = 'entity;scheme="http://schemas.ogf.org/occi/core#";class="kind"'

          expect(entity.to_header).to eql(expected)
        end

        it 'renders instance with attributes in HTTP Header correctly' do
          entity.actions << testaction
          entity.title = 'TestTitle'
          entity.location = '/TestLoc/1'
          entity.mixins <<  'http://example.com/mynamespace#mymixin'

          expected = Hashie::Mash.new
          expected['Category'] = 'entity;scheme="http://schemas.ogf.org/occi/core#";class="kind",mymixin;scheme="http://example.com/mynamespace#";class="mixin"'
          expected['X-OCCI-Attribute'] = 'occi.core.title="TestTitle"'
          expected['Link'] = '</TestLoc/1?action=testaction>;rel=http://schemas.ogf.org/occi/core/entity/action#testaction'

          expect(entity.to_header).to eql(expected)
        end
      end

      context '.check' do
        let(:attrs){ attrs = Occi::Core::Attributes.new }

        let(:defs){
          defs = Occi::Core::Attributes.new
          defs['numbertype'] =   { :type => 'number',
                                           :default => 42,
                                           :mutable => true }
          defs['stringtype'] =   { :type => 'string',
                                           :pattern => '[adefltuv]+',
                                           :default => 'defaultvalue', 
                                           :mutable => true }
          defs['booleantype'] =  { :type => 'boolean',
                                           :default => true, 
                                           :mutable => true }
          defs }

        context 'unsupported types' do
          before(:each){ Occi::Settings['compatibility']=false 
                         Occi::Settings['verify_attribute_pattern']=true }
          after(:each) { Occi::Settings.reload! }
          it 'refuses unsupportedi type' #do
#            expect{attrs['numbertype'] = Hashie::Mash.new }.to raise_error(Occi::Errors::AttributePropertyTypeError)
#          end
        end

        context 'defaults' do
          before(:each){ Occi::Settings['compatibility']=false 
                         Occi::Settings['verify_attribute_pattern']=true }
          after(:each) { Occi::Settings.reload! }

          it 'sets numeric default' do
            attributes = Occi::Core::Entity.check attrs, defs, true
            expect(attributes['numbertype']).to eq 42
          end
          it 'sets string default' do
            attributes = Occi::Core::Entity.check attrs, defs, true
            expect(attributes['stringtype']).to eq 'defaultvalue'
          end
          it 'sets boolean default' do
            attributes = Occi::Core::Entity.check attrs, defs, true
            expect(attributes['booleantype']).to eq true
          end
          it 'can be checked twice in a row' do
            attributes = Occi::Core::Entity.check attrs, defs, true
            expect{ bttributes = Occi::Core::Entity.check attributes, defs, true }.to_not raise_exception
          end
#          attrs['stringtype'] = 'stringvalue'
#          attrs['booleantype'] = false


        end




      end

    end
  end
end
