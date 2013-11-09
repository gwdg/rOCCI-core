module Occi
  describe "Model" do

    context '#get_by_id' do

      context 'Core model' do
        let(:model){ Occi::Model.new }
        it 'returns correct kind for entity' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/core#entity')).to be_kind_of Occi::Core::Kind
        end

        it 'returns correct kind for resource' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/core#resource')).to be_kind_of Occi::Core::Kind
        end

        it 'returns correct kind for resource' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/core#link')).to be_kind_of Occi::Core::Kind
        end
      end

      context 'Infrastructure model' do
        let(:model){ model = Occi::Model.new 
          model.register_infrastructure
          model
        }

        it 'returns correct kind for compute' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure#compute')).to be_kind_of Occi::Core::Kind
        end

        it 'returns correct kind for os_tpl' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure#os_tpl')).to be_kind_of Occi::Core::Mixin
        end

        it 'returns correct kind for resource_tpl' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure#resource_tpl')).to be_kind_of Occi::Core::Mixin
        end

        it 'returns correct kind for network' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure#network')).to be_kind_of Occi::Core::Kind
        end

        it 'returns correct kind for ipnetwork' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure/network#ipnetwork')).to be_kind_of Occi::Core::Mixin
        end

        it 'returns correct kind for networkinterface' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure#networkinterface')).to be_kind_of Occi::Core::Kind
        end

        it 'returns correct kind for ipnetworkinterface' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure/networkinterface#ipnetworkinterface')).to be_kind_of Occi::Core::Mixin
        end

        it 'returns correct kind for storage' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure#storage')).to be_kind_of Occi::Core::Kind
        end

        it 'returns correct kind for storagelink' do
          expect(model.get_by_id('http://schemas.ogf.org/occi/infrastructure#storagelink')).to be_kind_of Occi::Core::Kind
        end

      end
    end

    context '#get' do
      it "returns all registered categories" do
        model = Occi::Model.new
        collection = model.get
        expected=Marshal.restore("\x04\bo:\x10Occi::Model\n:\v@kindso:\x16Occi::Core::Kinds\x06:\n@hash{\bo:\x15Occi::Core::Kind\x0E:\f@schemeI\"&http://schemas.ogf.org/occi/core#\x06:\x06EF:\n@termI\"\ventity\x06;\vF:\v@titleI\"\ventity\x06;\vF:\x10@attributesC:\eOcci::Core::Attributes{\x06I\"\tocci\x06;\vFC;\x0F{\x06I\"\tcore\x06;\vFC;\x0F{\tI\"\aid\x06;\vFo:\eOcci::Core::Properties\v:\r@default0:\n@typeI\"\vstring\x06;\vF:\x0E@requiredF:\r@mutableF:\r@patternI\"A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\x06;\vF:\x11@description0I\"\b_id\x06;\vFo;\x10\v;\x110;\x12@\x13;\x13F;\x14F;\x15@\x14;\x160I\"\ntitle\x06;\vFo;\x10\v;\x110;\x12I\"\vstring\x06;\vF;\x13F;\x14T;\x15I\"\a.*\x06;\vF;\x160I\"\v_title\x06;\vFo;\x10\v;\x110;\x12@\x19;\x13F;\x14T;\x15@\x1A;\x160:\f@parent0:\r@actionso:\x18Occi::Core::Actions\x06;\b{\x00:\x0E@entitieso:\x19Occi::Core::Entities\x06;\b{\x00:\x0E@locationI\"\r/entity/\x06;\vF:\v@model@\x00To;\t\x0E;\nI\"&http://schemas.ogf.org/occi/core#\x06;\vF;\fI\"\rresource\x06;\vF;\rI\"\rresource\x06;\vF;\x0EC;\x0F{\x06@\rC;\x0F{\x06@\x0FC;\x0F{\v@\x11@\x12@\x15@\x16@\x17@\x18@\e@\x1CI\"\fsummary\x06;\vFo;\x10\v;\x110;\x12I\"\vstring\x06;\vF;\x13F;\x14T;\x15I\"\a.*\x06;\vF;\x160I\"\r_summary\x06;\vFo;\x10\v;\x110;\x12@+;\x13F;\x14T;\x15@,;\x160;\x17@\b;\x18o;\x19\x06;\b{\x00;\x1Ao;\e\x06;\b{\x06o:\x19Occi::Core::Resource\r:\n@kind@\":\f@mixinso:\x17Occi::Core::Mixins\b;\b{\x00;\x1Do;\x00\n;\x06o;\a\x06;\b{\b@\bT@\"To;\t\x0E;\nI\"&http://schemas.ogf.org/occi/core#\x06;\vF;\fI\"\tlink\x06;\vF;\rI\"\tlink\x06;\vF;\x0EC;\x0F{\x06@\rC;\x0F{\x06@\x0FC;\x0F{\r@\x11@\x12@\x15@\x16@\x17@\x18@\e@\x1CI\"\vtarget\x06;\vFo;\x10\v;\x110;\x12I\"\vstring\x06;\vF;\x13F;\x14T;\x15I\"\a.*\x06;\vF;\x160I\"\f_target\x06;\vFo;\x10\v;\x110;\x12@B;\x13F;\x14T;\x15@C;\x160I\"\vsource\x06;\vFo;\x10\v;\x110;\x12I\"\vstring\x06;\vF;\x13F;\x14T;\x15I\"\a.*\x06;\vF;\x160I\"\f_source\x06;\vFo;\x10\v;\x110;\x12@H;\x13F;\x14T;\x15@I;\x160;\x17@\b;\x18o;\x19\x06;\b{\x00;\x1Ao;\e\x06;\b{\x06o:\x15Occi::Core::Link\x0F;\x1F@9; o;!\b;\b{\x00;\x1D@6:\f@entity@P;\x0EIC;\x0F{\x06@\rIC;\x0F{\x06@\x0FIC;\x0F{\r@\x11I\")45284ebc-3397-468b-9d3b-863a24075ea2\x06;\vT@\x15@\x16@\x170@\e@\x1C@@0@D@E@F0@J@K\x06:\x0F@convertedT\x06;$T\x06;$T;\x18o;\x19\a;\b{\x00;\x1D@6;\x1C0:\t@rel@9:\f@target0;\x1D@6:\b@id@V:\f@source0T;\x1CI\"\v/link/\x06;\vF;\x1D@\x00T; o;!\x06;\b{\x00;\x18o;\x19\x06;\b{\x00:\x0F@resourceso:\x1AOcci::Core::Resources\x06;\b{\x00:\v@linkso:\x16Occi::Core::Links\x06;\b{\x00;\#@3;\x0EIC;\x0F{\x06@\rIC;\x0F{\x06@\x0FIC;\x0F{\v@\x11I\")aa7baa55-23dc-42fe-aa2d-45fba74d1a4e\x06;\vT@\x15@\x16@\x170@\e@\x1C@)0@-@.\x06;$T\x06;$T\x06;$T;\x18o;\x19\a;\b{\x00;\x1D@6;\x1C0;+o;,\a;\b{\x00;\x1D@6;\x1D@6;'@eT;\x1CI\"\x0F/resource/\x06;\vF;\x1D@\x00T@9T; o;!\x06;\b{\x00;\x18o;\x19\x06;\b{\x00;)o;*\x06;\b{\x00;+o;,\x06;\b{\x00")
        expect(collection).to eql expected
      end

      context "for categories with filter" do
        model = Occi::Model.new
        model.register_infrastructure
        network = Occi::Infrastructure::Network.kind
        collection = model.get(network)
        
        it 'returns the right kind' do
          expect(collection).to be_kind_of Occi::Collection
        end

        it 'returns the right number of kinds' do
          expect(collection.kinds.count).to eql 1
        end

        it 'returns the right number of kinds' do
          expect(collection.kinds).to have(1).kind
        end

        it 'starts with a network kind' do
          expect(collection.kinds.first).to eql network
        end

        it 'has empty mixins' do
          expect(collection.mixins).to be_empty
        end

        it 'has empty actions' do
          expect(collection.actions).to be_empty
        end

        it 'has empty resources' do
          expect(collection.resources).to be_empty
        end

        it 'has empty links' do
          expect(collection.links).to be_empty
        end
      end
    end

    context '#register' do
      let(:kind){ Occi::Core::Kind.new }
      let(:mixin){ Occi::Core::Mixin.new }
      let(:action){ Occi::Core::Action.new }
      let(:model){ model = Occi::Model.new 
        model.register(kind)
        model.register(mixin)
        model.register(action)
        model
      }

      it 'registers a kind' do
        expect(model.kinds.include?(kind)).to eql true
      end

      it 'registers a mixin' do
        expect(model.mixins.include?(mixin)).to eql true
      end

      it 'registers an action' do
        expect(model.actions.include?(action)).to eql true
      end
    end

    context '#unregister' do
      let(:kind){ Occi::Core::Kind.new }
      let(:mixin){ Occi::Core::Mixin.new }
      let(:action){ Occi::Core::Action.new }
      let(:model){ model = Occi::Model.new
        model.register(kind)
        model.register(mixin)
        model.register(action)
        model
      }

      it 'unregisters a kind' do
        model.unregister(kind)
        expect(model.kinds.include?(kind)).to eql false
      end

      it 'unregisters a mixin' do
        model.unregister(mixin)
        expect(model.mixins.include?(mixin)).to eql false
      end

      it 'unregisters an action' do
        model.unregister(action)
        expect(model.actions.include?(action)).to eql false
      end
    end

    context '#register_collection' do
      let(:kind){ Occi::Core::Kind.new }
      let(:mixin){ Occi::Core::Mixin.new }
      let(:action){ Occi::Core::Action.new }
      let(:collection) { collection = Occi::Collection.new
        collection << kind
        collection << mixin
        collection << action
        collection
      }
      let(:model){ model = Occi::Model.new
        model.register_collection(collection)
        model
      }

      it 'registers a kind' do
        expect(model.kinds.include?(kind)).to eql true
      end

      it 'registers a mixin' do
        expect(model.mixins.include?(mixin)).to eql true
      end

      it 'registers an action' do
        expect(model.actions.include?(action)).to eql true
      end
    end

    context '#reset' do
      let(:entity){ Occi::Core::Entity.new 'http://example.org/test/schema#testentity' }
      let(:kind){ kind = Occi::Core::Kind.new 
        kind.entities << entity 
        kind }
      let(:mixin){ mixin = Occi::Core::Mixin.new 
        mixin.entities << entity
        mixin }
      let(:action){ Occi::Core::Action.new }
      let(:model){ model = Occi::Model.new
        model.register(kind)
        model.register(mixin)
        model.register(action)
        model
      }

      before(:each){ model.reset }

      it 'unregisters entities from kinds' do
        found = false
        model.kinds.each { |kind| found = true if kind.entities.include?(entity) }
        expect(found).to eql false
      end

      it 'unregisters entities from mixins' do
        found = false
        model.mixins.each { |mixin| found = true if mixin.entities.include?(entity) }
        expect(found).to eql false
      end
      
    end


  end
end
