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
        expected = File.open("spec/occi/parser/text_samples/occi_model_categories.expected", "rt").read
        expect(collection.to_text).to eql expected
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

    context '#register_files' do
      context 'for correct and existing files' do
        let(:model){ model = Occi::Model.new
          model.register_files('spec/occi/collection_samples')
          model
        }

        it 'read the right number of mixins' do
          expect(model.mixins.count).to eql 2
        end

        it 'read the right number of actions' do
          expect(model.actions.count).to eql 2
        end

        it 'read the right number of resources' do
          expect(model.resources.count).to eql 2
        end

        it 'read the right number of links' do
          expect(model.links.count).to eql 2
        end

        it 'read the action' do
          expect(model.action.blank?).to eql false
        end
      end

      context 'for nonexistent directory' do
        it 'fails gracefully' do
          model = Occi::Model.new
          expect{ model.register_files('this/directory/does/not/exist') }.to raise_exception(ArgumentError)
        end
      end
    end
  end
end
