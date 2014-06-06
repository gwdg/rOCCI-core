module Occi
  module Core
    describe Entity do
      let(:entity){
        entity = Occi::Core::Entity.new
        entity.id = 'baf1'
        entity
      }
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
        it 'accepts kind from string' do
          entity.kind = 'http://example.com/testnamespace#test'
          expect(entity.kind).to eql Com::Example::Testnamespace::Test
        end

        it 'accepts kind from class' do
          entity.kind = Com::Example::Testnamespace::Test
          expect(entity.kind).to eql Com::Example::Testnamespace::Test
        end
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

          it 'gets normalized to a relative path' do
            entity.location = 'http://example.org/entity/12'
            expect(entity.location).to eq '/entity/12'
          end

          it 'can be set to nil and default to /kind/id' do
            entity.location = nil
            expect(entity.location).to eq '/entity/baf1'
          end

          it 'will not duplicate slashes' do
            entity.id = '//baf1'
            expect(entity.location).to eq '/entity/baf1'
          end

          it 'will not duplicate kind location' do
            entity.id = '/entity/baf1'
            expect(entity.location).to eq '/entity/baf1'
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
          expected = %Q|Category: entity;scheme="http://schemas.ogf.org/occi/core#";class="kind";location="/entity/";title="entity"
X-OCCI-Attribute: occi.core.id="baf1"|
          expect(entity.to_text).to eq(expected)
        end

        it 'renders instance with attributes in text correctly' do
          entity.actions << testaction
          entity.title = 'TestTitle'
          entity.location = '/TestLoc/1'
          entity.mixins <<  'http://example.com/mynamespace#mymixin'

          expected = %Q|Category: entity;scheme="http://schemas.ogf.org/occi/core#";class="kind";location="/entity/";title="entity"
Category: mymixin;scheme="http://example.com/mynamespace#";class="mixin";location="/mixin/mymixin/";title=""
X-OCCI-Attribute: occi.core.id="baf1"
X-OCCI-Attribute: occi.core.title="TestTitle"
Link: </TestLoc/1?action=testaction>;rel="http://schemas.ogf.org/occi/core/entity/action#testaction"|
          expect(entity.to_text).to eq(expected)
        end
      end

      context '#to_header' do
        it 'renders fresh instance in HTTP Header correctly' do
          expected = Hashie::Mash.new
          expected['Category'] = 'entity;scheme="http://schemas.ogf.org/occi/core#";class="kind";location="/entity/";title="entity"'
          expected['X-OCCI-Attribute'] = 'occi.core.id="baf1"'

          expect(entity.to_header).to eql(expected)
        end

        it 'renders instance with attributes in HTTP Header correctly' do
          entity.actions << testaction
          entity.title = 'TestTitle'
          entity.location = '/TestLoc/1'
          entity.mixins <<  'http://example.com/mynamespace#mymixin'

          expected = Hashie::Mash.new
          expected['Category'] = 'entity;scheme="http://schemas.ogf.org/occi/core#";class="kind";location="/entity/";title="entity",mymixin;scheme="http://example.com/mynamespace#";class="mixin";location="/mixin/mymixin/";title=""'
          expected['X-OCCI-Attribute'] = 'occi.core.id="baf1",occi.core.title="TestTitle"'
          expected['Link'] = '</TestLoc/1?action=testaction>;rel="http://schemas.ogf.org/occi/core/entity/action#testaction"'

          expect(entity.to_header).to eql(expected)
        end
      end

      context '#as_json' do
        it 'renders element as JSON' do
          entity.actions << testaction

          expected = Hashie::Mash.new JSON.parse('{"kind":"http://schemas.ogf.org/occi/core#entity","actions":["http://schemas.ogf.org/occi/core/entity/action#testaction"],"attributes":{"occi":{"core":{"id":"baf1"}}},"id":"baf1"}')
          expect(entity.as_json).to eql expected
        end
      end

      context '#check' do
        let(:defs){
          defs = Occi::Core::Attributes.new
          defs['occi.core.id'] = { :type=> 'string',
                                   :required => true }
          defs['numbertype'] =   { :type => 'number',
                                           :default => 42,
                                           :mutable => true,
                                           :pattern => '^[0-9]+'  }
          defs['stringtype'] =   { :type => 'string',
                                           :pattern => '[adefltuv]+',
                                           :default => 'defaultvalue',
                                           :mutable => true }
          defs['booleantype'] =  { :type => 'boolean',
                                           :default => true,
                                           :mutable => true}
          defs['booleantypefalse'] =  { :type => 'boolean',
                                           :default => false,
                                           :mutable => true }
          defs['booleantypepattern'] =  { :type => 'boolean',
                                           :default => true,
                                           :mutable => true,
                                           :pattern => true }
          defs }
        let(:kind){ Occi::Core::Kind.new 'http://schemas.ogf.org/occi/core#', 'testkind', 'Test Kind', defs }
        let(:model){ model = Occi::Model.new
          model.register(kind)
          model.register(defmixin)
          model }
        let(:defmixin){ defmixin = Occi::Core::Mixin.new 'http://schemas.ogf.org/occi/core#', 'testmixin'
          defmixin.attributes['mixinstring'] =  { :type => 'string',
                                               :pattern => '.*',
                                               :default => 'mixdefault',
                                               :mutable => true }
          defmixin }
        let(:mixin){ Occi::Core::Mixin.new 'http://schemas.ogf.org/occi/core#', 'testmixin' }
        let(:undefmixin){ Occi::Core::Mixin.new 'http://schemas.ogf.org/occi/core#', 'fake_mixin' }

        let(:entity){ entity = Occi::Core::Entity.new(kind, [], defs)
          entity.model = model
          entity.mixins << mixin
          entity }


        before(:each){ Occi::Settings['compatibility']=false
                       Occi::Settings['verify_attribute_pattern']=true }
        after(:each) { Occi::Settings.reload! }

        context 'unsupported types' do
          it 'refuses unsupported type' do
            expect{ entity.attributes['othertype'] = { :type => 'other', :default => 'defaultvalue' } }.to raise_exception(Occi::Errors::AttributePropertyTypeError)
          end
        end

        context 'defaults' do
          context 'setting defaults' do
            it 'sets numeric default' do
              entity.check(true)
              expect(entity.attributes['numbertype']).to eq 42
            end
            it 'sets string default' do
              entity.check(true)
              expect(entity.attributes['stringtype']).to eq 'defaultvalue'
            end
            it 'sets mixin string default' do
              entity.check(true)
              expect(entity.attributes['mixinstring']).to eq 'mixdefault'
            end
            it 'sets boolean default if true' do
              entity.check(true)
              expect(entity.attributes['booleantype']).to eq true
            end
            it 'sets boolean default if false' do
              entity.check(true)
              expect(entity.attributes['booleantypefalse']).to eq false
            end
            it 'can be checked twice in a row' do
              entity.check(true)
              expect{ entity.check(true) }.to_not raise_exception
            end
            it 'skips numeric default' do
              entity.attributes['numbertype'] = 12
              entity.check(true)
              expect(entity.attributes['numbertype']).to eq 12
            end
            it 'skips string default' do
              entity.attributes['stringtype'] = 'fault'
              entity.check(true)
              expect(entity.attributes['stringtype']).to eq 'fault'
            end
            it 'skips boolean default if true' do
              entity.attributes['booleantype'] = false
              entity.check(true)
              expect(entity.attributes['booleantype']).to eq false
            end
            it 'skips boolean default if false' do
              entity.attributes['booleantypefalse'] = true
              entity.check(true)
              expect(entity.attributes['booleantypefalse']).to eq true
            end
          end

          context 'patterns' do
            it 'checks string pattern' do
              expect{ entity.attributes['stringtype'] = 'bflmpsvz' }.to raise_exception(Occi::Errors::AttributeTypeError)
            end
            it 'checks numeric pattern' do
              expect{ entity.attributes['numbertype'] = -32 }.to raise_exception(Occi::Errors::AttributeTypeError)
            end
            it 'checks boolean pattern' do
              expect{ entity.attributes['booleantypepattern'] = false }.to raise_exception(Occi::Errors::AttributeTypeError)
            end
          end
        end

        context 'exceptions' do
          it 'raisees exception for missing model' do
            ent = Occi::Core::Entity.new(kind, [], defs)
            expect{ ent.check(true) }.to raise_exception ArgumentError
          end

          it 'raises exception for nonexistent kind' do
            ent = Occi::Core::Entity.new(kind, [], defs)
            mod = Occi::Model.new
            ent.model = mod
            expect{ ent.check(true) }.to raise_exception Occi::Errors::KindNotDefinedError
          end

          it 'raises expection for nonexistent mixins' do
            ent = Occi::Core::Entity.new(kind, [], defs)
            ent.model = model
            ent.mixins << undefmixin
            expect{ ent.check }.to raise_exception Occi::Errors::CategoryNotDefinedError
          end
        end
      end

      context '#attribute_properties' do
        it 'gets attribute properties' do
          properties = entity.attribute_properties
          expect(properties.occi.core.count).to eql 4
        end
      end

      context '#empty?' do

        it 'returns false for a new instance with defaults' do
          expect(entity.empty?).to be false
        end

        it 'returns true for an instance without a kind' do
          ent = entity.clone
          ent.kind = nil

          expect(ent.empty?).to be true
        end

        it 'returns true for an instance without an identifier' do
          ent = entity.clone
          ent.id = nil

          expect(ent.empty?).to be true
        end

      end

    end
  end
end
