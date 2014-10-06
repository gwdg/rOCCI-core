module Occi
  describe Collection do

    context 'initialization' do
      let(:collection){ collection = Occi::Collection.new }

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
      let(:collection){ collection = Occi::Collection.new }
      it 'registers a model' do
        expect(collection.model).to be_kind_of Occi::Model
      end
    end

    context '#resources' do
      let(:collection){ collection = Occi::Collection.new }
      it 'can create a new OCCI Resource' do
        collection.resources.create 'http://schemas.ogf.org/occi/core#resource'
        expect(collection.resources.first).to be_kind_of Occi::Core::Resource
      end
    end

    context '#check' do
      let(:collection){ collection = Occi::Collection.new }

      it 'checks against model without failure' do
        collection.resources.create 'http://schemas.ogf.org/occi/core#resource'
        expect{ collection.check }.to_not raise_error
      end

      it 'does not raise an error for unknown categories by default' do
        collection.kinds << Occi::Core::Kind.new('http://example.org/test/stuff#', 'here')
        expect { collection.check }.to_not raise_error
      end

      it 'raises an error for unknown categories when requested' do
        collection.kinds << Occi::Core::Kind.new('http://example.org/test/stuff#', 'here')
        expect { collection.check(true) }.to raise_error
      end

    end

    context '#get_related_to' do
      let(:collection){ collection = Occi::Collection.new }
      before(:each){
        collection.kinds << Occi::Core::Resource.kind
        collection.kinds << Occi::Core::Link.kind
      }
      it 'gets Entity as a related kind' do
        expect(collection.get_related_to(Occi::Core::Entity.kind)).to eql collection
        expect(collection.get_related_to(Occi::Core::Entity.kind.type_identifier)).to eql collection
      end

      it 'gets Resource as a related kind' do
        expect(collection.get_related_to(Occi::Core::Resource.kind).kinds.first).to eql Occi::Core::Resource.kind
        expect(collection.get_related_to(Occi::Core::Resource.kind.type_identifier).kinds.first).to eql Occi::Core::Resource.kind
      end

      it 'gets Link as a related kind' do
        expect(collection.get_related_to(Occi::Core::Link.kind).kinds.first).to eql Occi::Core::Link.kind
        expect(collection.get_related_to(Occi::Core::Link.kind.type_identifier).kinds.first).to eql Occi::Core::Link.kind
      end

      it 'fails loudly when no category is given' do
        expect { collection.get_related_to("") } .to raise_error RuntimeError
        expect { collection.get_related_to(nil) } .to raise_error RuntimeError
      end
    end

    context '#merge' do
      let(:collection){ collection = Occi::Collection.new }
      before(:each) {
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.action = Occi::Core::ActionInstance.new
        collection.resources << Occi::Core::Resource.new
        collection.links << Occi::Core::Link.new
      }
      context 'two fully initiated collections' do
        let(:action){ Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action' }
        let(:coll2){
          coll2 = Occi::Collection.new
          coll2.kinds << "http://schemas.ogf.org/occi/infrastructure#storage"
          coll2.mixins << "http://example.com/occi/tags#another_mixin"
          coll2.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#stop"
          coll2.action = Occi::Core::ActionInstance.new action
          coll2.resources << Occi::Core::Resource.new
          coll2.links << Occi::Core::Link.new
          coll2
        }
        let(:merged){ collection.merge(coll2, collection) }

        context 'resulting collection' do
          it 'has the correct number of kinds' do
            expect(merged.kinds.count).to eql 2
          end

          it 'has the correct number of mixins' do
            expect(merged.mixins.count).to eql 2
          end

          it 'has the correct number of actions' do
            expect(merged.actions.count).to eql 2
          end

          it 'has the correct number of resources' do
            expect(merged.resources.count).to eql 2
          end

          it 'has the correct number of links' do
            expect(merged.links.count).to eql 2
          end

          it 'inherits action from the other collection' do
            expect(merged.action.action.term).to eql "testaction"
          end

          it 'does not inherit action from first collection' do
            expect(merged.action.action.term).to_not eql "action_instance"
          end

          it 'holds kinds from first collection' do
            expect(collection.kinds.subset?(merged.kinds)).to eql true
          end

          it 'holds mixins from first collection' do
            expect(collection.mixins.subset?(merged.mixins)).to eql true
          end

          it 'holds actions from first collection' do
            expect(collection.actions.subset?(merged.actions)).to eql true
          end

          it 'holds resources from first collection' do
            expect(collection.resources.subset?(merged.resources)).to eql true
          end

          it 'holds links from first collection' do
            expect(collection.links.subset?(merged.links)).to eql true
          end

          it 'holds kinds from other collection' do
            expect(coll2.kinds.subset?(merged.kinds)).to eql true
          end

          it 'holds mixins from other collection' do
            expect(coll2.mixins.subset?(merged.mixins)).to eql true
          end

          it 'holds actions from other collection' do
            expect(coll2.actions.subset?(merged.actions)).to eql true
          end

          it 'holds resources from other collection' do
            expect(coll2.resources.subset?(merged.resources)).to eql true
          end

          it 'holds links from other collection' do
            expect(coll2.links.subset?(merged.links)).to eql true
          end

          it 'does not replace first collection' do
            expect(merged).to_not eql collection
          end
        end

        context 'first original' do
          it 'kept the correct number of kinds' do
            expect(collection.kinds.count).to eql 1
          end

          it 'kept the correct number of mixins' do
            expect(collection.mixins.count).to eql 1
          end

          it 'kept the correct number of actions' do
            expect(collection.actions.count).to eql 1
          end

          it 'kept the correct number of resources' do
            expect(collection.resources.count).to eql 1
          end

          it 'kept the correct number of links' do
            expect(collection.links.count).to eql 1
          end
        end

        context 'second original' do
          it 'kept the correct number of kinds' do
            expect(coll2.kinds.count).to eql 1
          end

          it 'kept the correct number of mixins' do
            expect(coll2.mixins.count).to eql 1
          end

          it 'kept the correct number of actions' do
            expect(coll2.actions.count).to eql 1
          end

          it 'kept the correct number of resources' do
            expect(coll2.resources.count).to eql 1
          end

          it 'kept the correct number of links' do
            expect(coll2.links.count).to eql 1
          end
        end
      end

      it 'copes with an empty collection' do
        emptycol = Occi::Collection.new
        expect{merged = collection.merge(emptycol, collection)}.to_not raise_error
      end

      it 'copes with both collections empty' do
        empty1 = Occi::Collection.new
        empty2 = Occi::Collection.new
        expect{merged = collection.merge(empty1, empty2)}.to_not raise_error
      end

    end

    context '#merge!' do
      let(:collection){ collection = Occi::Collection.new
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.action = Occi::Core::ActionInstance.new
        collection.resources << Occi::Core::Resource.new
        collection.links << Occi::Core::Link.new
        collection
      }
      context 'two fully initiated collections' do
        let(:action){ Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action' }
        let(:coll2){
          coll2 = Occi::Collection.new
          coll2.kinds << "http://schemas.ogf.org/occi/infrastructure#storage"
          coll2.mixins << "http://example.com/occi/tags#another_mixin"
          coll2.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#stop"
          coll2.action = Occi::Core::ActionInstance.new action
          coll2.resources << Occi::Core::Resource.new
          coll2.links << Occi::Core::Link.new
          coll2
        }
        before(:each) { collection.merge!(coll2) }
        context 'resulting collection' do
          it 'has the correct number of kinds' do
            expect(collection.kinds.count).to eql 2
          end

          it 'has the correct number of mixins' do
            expect(collection.mixins.count).to eql 2
          end

          it 'has the correct number of actions' do
            expect(collection.actions.count).to eql 2
          end

          it 'has the correct number of resources' do
            expect(collection.resources.count).to eql 2
          end

          it 'has the correct number of links' do
            expect(collection.links.count).to eql 2
          end

          it 'inherits action from the other collection' do
            expect(collection.action.action.term).to eql "testaction"
          end

          it 'does not inherit action from first collection' do
            expect(collection.action.action.term).to_not eql "action_instance"
          end

          it 'holds kinds from other collection' do
            expect(coll2.kinds.subset?(collection.kinds)).to eql true
          end

          it 'holds mixins from other collection' do
            expect(coll2.mixins.subset?(collection.mixins)).to eql true
          end

          it 'holds actions from other collection' do
            expect(coll2.actions.subset?(collection.actions)).to eql true
          end

          it 'holds resources from other collection' do
            expect(coll2.resources.subset?(collection.resources)).to eql true
          end

          it 'holds links from other collection' do
            expect(coll2.links.subset?(collection.links)).to eql true
          end
        end

        context 'the other collection' do
          it 'kept the correct number of kinds' do
            expect(coll2.kinds.count).to eql 1
          end

          it 'kept the correct number of mixins' do
            expect(coll2.mixins.count).to eql 1
          end

          it 'kept the correct number of actions' do
            expect(coll2.actions.count).to eql 1
          end

          it 'kept the correct number of resources' do
            expect(coll2.resources.count).to eql 1
          end

          it 'kept the correct number of links' do
            expect(coll2.links.count).to eql 1
          end
        end
      end
      it 'copes with other collection empty' do
        emptycol = Occi::Collection.new
        expect{ collection.merge!(emptycol) }.to_not raise_error
      end

      it 'copes with self empty' do
        emptycol = Occi::Collection.new
        expect{ emptycol.merge!(collection) }.to_not raise_error
      end

      it 'copes with both collections empty' do
        empty1 = Occi::Collection.new
        empty2 = Occi::Collection.new
        expect{ empty1.merge(empty2) }.to_not raise_error
      end

      it 'combines two empty sets into another empty one' do
        empty1 = Occi::Collection.new
        empty2 = Occi::Collection.new
        empty1.merge(empty2)
        expect(empty1.empty?).to eql true
      end

    end

    context '#intersect' do
      let(:collection){ collection = Occi::Collection.new }
      before(:each) {
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#network"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.mixins << "http://example.com/occi/tags#still_another_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#restart"
        collection.action = Occi::Core::ActionInstance.new
        collection.resources << Occi::Core::Resource.new
        collection.resources << Occi::Core::Resource.new
        collection.links << Occi::Core::Link.new
        collection.links << Occi::Core::Link.new
      }
      context 'two fully initiated collections' do
        let(:action){ Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action' }
        let(:coll2){
          coll2 = Occi::Collection.new
          coll2.kinds << "http://schemas.ogf.org/occi/infrastructure#storage"
          coll2.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
          coll2.mixins << "http://example.com/occi/tags#another_mixin"
          coll2.mixins << "http://example.com/occi/tags#my_mixin"
          coll2.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#stop"
          coll2.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#restart"
          coll2.action = Occi::Core::ActionInstance.new action
          coll2.resources << Occi::Core::Resource.new
          coll2.resources << collection.resources.first
          coll2.links << Occi::Core::Link.new
          coll2.links << collection.resources.first
          coll2
        }
        let(:isection){ collection.intersect(coll2, collection) }

        context 'resulting collection' do
          it 'has the correct number of kinds' do
            expect(isection.kinds.count).to eql 1
          end

          it 'has the correct number of mixins' do
            expect(isection.mixins.count).to eql 1
          end

          it 'has the correct number of actions' do
            expect(isection.actions.count).to eql 1
          end

          it 'has the correct number of resources' do
            expect(isection.resources.count).to eql 1
          end

          it 'has the correct number of links' do
            expect(isection.links.count).to eql 1
          end

          it 'does not include unequal actions' do
            expect(isection.action.blank?).to eql true
          end

          it 'holds kinds from first collection' do
            expect(isection.kinds.subset?(collection.kinds)).to eql true
          end

          it 'holds mixins from first collection' do
            expect(isection.mixins.subset?(collection.mixins)).to eql true
          end

          it 'holds actions from first collection' do
            expect(isection.actions.subset?(collection.actions)).to eql true
          end

          it 'holds resources from first collection' do
            expect(isection.resources.subset?(collection.resources)).to eql true
          end

          it 'holds links from first collection' do
            expect(isection.links.subset?(collection.links)).to eql true
          end

          it 'holds kinds from other collection' do
            expect(isection.kinds.subset?(coll2.kinds)).to eql true
          end

          it 'holds mixins from other collection' do
            expect(isection.mixins.subset?(coll2.mixins)).to eql true
          end

          it 'holds actions from other collection' do
            expect(isection.actions.subset?(coll2.actions)).to eql true
          end

          it 'holds resources from other collection' do
            expect(isection.resources.subset?(coll2.resources)).to eql true
          end

          it 'holds links from other collection' do
            expect(isection.links.subset?(coll2.links)).to eql true
          end

          it 'does not replace first collection' do
            expect(coll2.links.subset?(collection.links)).to_not eql true
          end
        end

        context 'first original' do
          it 'kept the correct number of kinds' do
            expect(collection.kinds.count).to eql 2
          end

          it 'kept the correct number of mixins' do
            expect(collection.mixins.count).to eql 2
          end

          it 'kept the correct number of actions' do
            expect(collection.actions.count).to eql 2
          end

          it 'kept the correct number of resources' do
            expect(collection.resources.count).to eql 2
          end

          it 'kept the correct number of links' do
            expect(collection.links.count).to eql 2
          end
        end

        context 'second original' do
          it 'kept the correct number of kinds' do
            expect(coll2.kinds.count).to eql 2
          end

          it 'kept the correct number of mixins' do
            expect(coll2.mixins.count).to eql 2
          end

          it 'kept the correct number of actions' do
            expect(coll2.actions.count).to eql 2
          end

          it 'kept the correct number of resources' do
            expect(coll2.resources.count).to eql 2
          end

          it 'kept the correct number of links' do
            expect(coll2.links.count).to eql 2
          end
        end
      end

      it 'copes with an empty collection' do
        emptycol = Occi::Collection.new
        expect{ isection = collection.intersect(emptycol, collection)}.to_not raise_error
      end

      it 'copes with both collections empty' do
        empty1 = Occi::Collection.new
        empty2 = Occi::Collection.new
        expect{ isection = collection.intersect(empty1, empty2)}.to_not raise_error
      end
    end
    context '#intersect!' do
      let(:collection){
        collection = Occi::Collection.new
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#network"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.mixins << "http://example.com/occi/tags#still_another_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#restart"
        collection.action = Occi::Core::ActionInstance.new
        collection.resources << Occi::Core::Resource.new
        collection.resources << Occi::Core::Resource.new
        collection.links << Occi::Core::Link.new
        collection.links << Occi::Core::Link.new
        collection }
      context 'two fully initiated collections' do
        let(:action){ Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action' }
        let(:coll2){
          coll2 = Occi::Collection.new
          coll2.kinds << "http://schemas.ogf.org/occi/infrastructure#storage"
          coll2.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
          coll2.mixins << "http://example.com/occi/tags#another_mixin"
          coll2.mixins << "http://example.com/occi/tags#my_mixin"
          coll2.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#stop"
          coll2.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#restart"
          coll2.action = Occi::Core::ActionInstance.new action
          coll2.resources << Occi::Core::Resource.new
          coll2.resources << collection.resources.first
          coll2.links << Occi::Core::Link.new
          coll2.links << collection.resources.first
          coll2
        }
        before(:each){ collection.intersect!(coll2) }

        context 'resulting collection' do
          it 'has the correct number of kinds' do
            expect(collection.kinds.count).to eql 1
          end

          it 'has the correct number of mixins' do
            expect(collection.mixins.count).to eql 1
          end

          it 'has the correct number of actions' do
            expect(collection.actions.count).to eql 1
          end

          it 'has the correct number of resources' do
            expect(collection.resources.count).to eql 1
          end

          it 'has the correct number of links' do
            expect(collection.links.count).to eql 1
          end

          it 'does not include unequal actions' do
            expect(collection.action.blank?).to eql true
          end

          it 'holds kinds from first collection' do
            expect(collection.kinds.subset?(collection.kinds)).to eql true
          end

          it 'holds mixins from first collection' do
            expect(collection.mixins.subset?(collection.mixins)).to eql true
          end

          it 'holds actions from first collection' do
            expect(collection.actions.subset?(collection.actions)).to eql true
          end

          it 'holds resources from first collection' do
            expect(collection.resources.subset?(collection.resources)).to eql true
          end

          it 'holds links from first collection' do
            expect(collection.links.subset?(collection.links)).to eql true
          end

          it 'holds kinds from other collection' do
            expect(collection.kinds.subset?(coll2.kinds)).to eql true
          end

          it 'holds mixins from other collection' do
            expect(collection.mixins.subset?(coll2.mixins)).to eql true
          end

          it 'holds actions from other collection' do
            expect(collection.actions.subset?(coll2.actions)).to eql true
          end

          it 'holds resources from other collection' do
            expect(collection.resources.subset?(coll2.resources)).to eql true
          end

          it 'holds links from other collection' do
            expect(collection.links.subset?(coll2.links)).to eql true
          end
        end

        context 'second original' do
          it 'kept the correct number of kinds' do
            expect(coll2.kinds.count).to eql 2
          end

          it 'kept the correct number of mixins' do
            expect(coll2.mixins.count).to eql 2
          end

          it 'kept the correct number of actions' do
            expect(coll2.actions.count).to eql 2
          end

          it 'kept the correct number of resources' do
            expect(coll2.resources.count).to eql 2
          end

          it 'kept the correct number of links' do
            expect(coll2.links.count).to eql 2
          end
        end
      end

      context 'collections with no intersection' do
        let(:action){ Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action' }
        let(:uniq1) {
          uniq1 = Occi::Collection.new
          uniq1.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
          uniq1.mixins << "http://example.com/occi/tags#my_mixin"
          uniq1.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
          uniq1.action = Occi::Core::ActionInstance.new
          uniq1.resources << Occi::Core::Resource.new
          uniq1.links << Occi::Core::Link.new
          uniq1
        }
        let(:uniq2) {
          uniq2 = Occi::Collection.new
          uniq2.kinds << "http://schemas.ogf.org/occi/infrastructure#storage"
          uniq2.mixins << "http://example.com/occi/tags#another_mixin"
          uniq2.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#stop"
          uniq2.action = Occi::Core::ActionInstance.new action
          uniq2.resources << Occi::Core::Resource.new
          uniq2.links << Occi::Core::Link.new
          uniq2
        }
        it 'works with both collections populated' do
          uniq1.intersect!(uniq2)
          expect(uniq1.empty?).to eql true
        end

        it 'works with both collections empty' do
          empty1 = Occi::Collection.new
          empty2 = Occi::Collection.new

          empty1.intersect!(empty2)
          expect(empty1.empty?).to eql true
        end

        it 'works with first collection empty' do
          empty = Occi::Collection.new

          uniq1.intersect!(empty)
          expect(empty.empty?).to eql true
        end

        it 'works with second collection empty' do
          empty = Occi::Collection.new

          empty.intersect!(uniq2)
          expect(empty.empty?).to eql true
        end
      end
    end

    context '#get_by_...' do
      let(:collection){ collection = Occi::Collection.new
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.action = Occi::Core::ActionInstance.new
        collection.resources << Occi::Core::Resource.new
        collection.links << Occi::Core::Link.new
        collection
      }

      context '#get_by_id' do
        it 'finds entity by id' do
          expect(collection.get_by_id(collection.links.first.id)).to eql collection.links.first
        end

        it 'finds category by id' do
          expect(collection.get_by_id("http://example.com/occi/tags#my_mixin")).to eql collection.mixins.first
        end

        it 'fails gracefully' do
          expect(collection.get_by_id("ID.notexist")).to eql nil
        end

        it 'fails loudly when no id is given' do
          expect { collection.get_by_id("") } .to raise_error RuntimeError
          expect { collection.get_by_id(nil) } .to raise_error RuntimeError
        end

      end

      context '#get_by_location' do
        it 'finds category by location' do
          expect(collection.get_by_location("/mixin/my_mixin/")).to eql collection.mixins.first
        end

        it 'finds category by instance location' do
          expect(collection.get_by_location("/compute/1")).to eql collection.kinds.first
        end

        it 'fails gracefully' do
          expect(collection.get_by_location("/notexist/")).to eql nil
        end

        it 'fails loudly when no location is given' do
          expect { collection.get_by_location("") } .to raise_error RuntimeError
          expect { collection.get_by_location(nil) } .to raise_error RuntimeError
        end
      end
    end

    context '#empty?' do
      let(:collection){ Occi::Collection.new }
      it 'returns true for empty collection' do
        expect(collection.empty?).to eql true
      end

      it 'does returns false for non-empty kinds' do
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        expect(collection.empty?).to eql false
      end

      it 'does returns false for non-empty mixnis' do
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        expect(collection.empty?).to eql false
      end

      it 'does returns false for non-empty actions' do
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        expect(collection.empty?).to eql false
      end

      it 'does returns false for non-empty action' do
        collection.action = Occi::Core::ActionInstance.new
        expect(collection.empty?).to eql false
      end

      it 'does returns false for non-empty resources' do
        collection.resources << Occi::Core::Resource.new
        expect(collection.empty?).to eql false
      end

      it 'does returns false for non-empty links' do
        collection.links << Occi::Core::Link.new
        expect(collection.empty?).to eql false
      end
    end

    context '#as_json' do
      it 'renders JSON correctly for a simple collection' do
        collection = Occi::Collection.new
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.action = Occi::Core::ActionInstance.new
        collection.resources << Occi::Core::Resource.new
        collection.links << Occi::Core::Link.new
        expected = "{\"actions\":[{\"scheme\":\"http://schemas.ogf.org/occi/infrastructure/compute/action#\",\"term\":\"start\",\"attributes\":{}}],\"kinds\":[{\"parent\":\"http://schemas.ogf.org/occi/core#resource\",\"related\":[\"http://schemas.ogf.org/occi/core#resource\"],\"actions\":[\"http://schemas.ogf.org/occi/infrastructure/compute/action#start\",\"http://schemas.ogf.org/occi/infrastructure/compute/action#stop\",\"http://schemas.ogf.org/occi/infrastructure/compute/action#restart\",\"http://schemas.ogf.org/occi/infrastructure/compute/action#suspend\"],\"location\":\"/compute/\",\"scheme\":\"http://schemas.ogf.org/occi/infrastructure#\",\"term\":\"compute\",\"title\":\"compute resource\",\"attributes\":{\"occi\":{\"core\":{\"id\":{\"type\":\"string\",\"required\":true,\"mutable\":false,\"pattern\":\"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\"},\"title\":{\"type\":\"string\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"},\"summary\":{\"type\":\"string\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"}},\"compute\":{\"architecture\":{\"type\":\"string\",\"required\":false,\"mutable\":true,\"pattern\":\"x86|x64\"},\"cores\":{\"type\":\"number\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"},\"hostname\":{\"type\":\"string\",\"required\":false,\"mutable\":true,\"pattern\":\"(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\\\-]*[a-zA-Z0-9])\\\\.)*\"},\"memory\":{\"type\":\"number\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"},\"speed\":{\"type\":\"number\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"},\"state\":{\"default\":\"inactive\",\"type\":\"string\",\"required\":false,\"mutable\":false,\"pattern\":\"inactive|active|suspended|error\"}}}}}],\"links\":[{\"kind\":\"http://schemas.ogf.org/occi/core#link\",\"attributes\":{\"occi\":{\"core\":{\"id\":\"#{collection.links.first.id}\"}}},\"id\":\"#{collection.links.first.id}\",\"rel\":\"http://schemas.ogf.org/occi/core#link\"}],\"mixins\":[{\"location\":\"/mixin/my_mixin/\",\"scheme\":\"http://example.com/occi/tags#\",\"term\":\"my_mixin\",\"attributes\":{}}],\"resources\":[{\"kind\":\"http://schemas.ogf.org/occi/core#resource\",\"attributes\":{\"occi\":{\"core\":{\"id\":\"#{collection.resources.first.id}\"}}},\"id\":\"#{collection.resources.first.id}\"}]}"

        hash=Hashie::Mash.new(JSON.parse(expected))
        expect(collection.as_json).to eql(hash)
      end

      it 'renders JSON for an empty collection' do
        collection = Occi::Collection.new
        hash=Hashie::Mash.new
        expect(collection.as_json).to eql(hash)
      end

      it 'renders JSON for a collection with no resources' do
        collection = Occi::Collection.new
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.action = Occi::Core::ActionInstance.new
        collection.links << Occi::Core::Link.new
        expected = "{\"actions\":[{\"scheme\":\"http://schemas.ogf.org/occi/infrastructure/compute/action#\",\"term\":\"start\",\"attributes\":{}}],\"kinds\":[{\"parent\":\"http://schemas.ogf.org/occi/core#resource\",\"related\":[\"http://schemas.ogf.org/occi/core#resource\"],\"actions\":[\"http://schemas.ogf.org/occi/infrastructure/compute/action#start\",\"http://schemas.ogf.org/occi/infrastructure/compute/action#stop\",\"http://schemas.ogf.org/occi/infrastructure/compute/action#restart\",\"http://schemas.ogf.org/occi/infrastructure/compute/action#suspend\"],\"location\":\"/compute/\",\"scheme\":\"http://schemas.ogf.org/occi/infrastructure#\",\"term\":\"compute\",\"title\":\"compute resource\",\"attributes\":{\"occi\":{\"core\":{\"id\":{\"type\":\"string\",\"required\":true,\"mutable\":false,\"pattern\":\"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\"},\"title\":{\"type\":\"string\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"},\"summary\":{\"type\":\"string\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"}},\"compute\":{\"architecture\":{\"type\":\"string\",\"required\":false,\"mutable\":true,\"pattern\":\"x86|x64\"},\"cores\":{\"type\":\"number\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"},\"hostname\":{\"type\":\"string\",\"required\":false,\"mutable\":true,\"pattern\":\"(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\\\-]*[a-zA-Z0-9])\\\\.)*\"},\"memory\":{\"type\":\"number\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"},\"speed\":{\"type\":\"number\",\"required\":false,\"mutable\":true,\"pattern\":\".*\"},\"state\":{\"default\":\"inactive\",\"type\":\"string\",\"required\":false,\"mutable\":false,\"pattern\":\"inactive|active|suspended|error\"}}}}}],\"links\":[{\"kind\":\"http://schemas.ogf.org/occi/core#link\",\"attributes\":{\"occi\":{\"core\":{\"id\":\"#{collection.links.first.id}\"}}},\"id\":\"#{collection.links.first.id}\",\"rel\":\"http://schemas.ogf.org/occi/core#link\"}],\"mixins\":[{\"location\":\"/mixin/my_mixin/\",\"scheme\":\"http://example.com/occi/tags#\",\"term\":\"my_mixin\",\"attributes\":{}}]}"

        hash=Hashie::Mash.new(JSON.parse(expected))
        expect(collection.as_json).to eql(hash)
      end
    end

    context '#to_text' do
      let(:collection){ Occi::Collection.new }
      it 'renders text correctly for a simple collection' do
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.action = Occi::Core::ActionInstance.new
        collection.resources << Occi::Core::Resource.new
        collection.links << Occi::Core::Link.new

        expected = "Category: compute;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";title=\"compute resource\";rel=\"http://schemas.ogf.org/occi/core#resource\";location=\"/compute/\";attributes=\"occi.core.id{immutable required} occi.core.title occi.core.summary occi.compute.architecture occi.compute.cores occi.compute.hostname occi.compute.memory occi.compute.speed occi.compute.state{immutable}\";actions=\"http://schemas.ogf.org/occi/infrastructure/compute/action#start http://schemas.ogf.org/occi/infrastructure/compute/action#stop http://schemas.ogf.org/occi/infrastructure/compute/action#restart http://schemas.ogf.org/occi/infrastructure/compute/action#suspend\"\nCategory: my_mixin;scheme=\"http://example.com/occi/tags#\";class=\"mixin\";location=\"/mixin/my_mixin/\"\nCategory: start;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\"\nCategory: resource;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/resource/\";title=\"resource\"\nX-OCCI-Attribute: occi.core.id=\"#{collection.resources.first.id}\"Link: <>;rel=\"http://schemas.ogf.org/occi/core#link\";self=\"/link/#{collection.links.first.id}\";category=\"http://schemas.ogf.org/occi/core#link\";occi.core.id=\"#{collection.links.first.id}\"Category: action_instance;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""
        expect(collection.to_text).to eql(expected)
      end

      it 'renders text correctly for an empty collection' do
        expected = ''
        expect(collection.to_text).to eql(expected)
      end

      it 'renders text correctly, kinds only' do
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        expected = "Category: compute;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";title=\"compute resource\";rel=\"http://schemas.ogf.org/occi/core#resource\";location=\"/compute/\";attributes=\"occi.core.id{immutable required} occi.core.title occi.core.summary occi.compute.architecture occi.compute.cores occi.compute.hostname occi.compute.memory occi.compute.speed occi.compute.state{immutable}\";actions=\"http://schemas.ogf.org/occi/infrastructure/compute/action#start http://schemas.ogf.org/occi/infrastructure/compute/action#stop http://schemas.ogf.org/occi/infrastructure/compute/action#restart http://schemas.ogf.org/occi/infrastructure/compute/action#suspend\"\n"
        expect(collection.to_text).to eql(expected)
      end

      it 'renders text correctly, mixins only' do
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        expected = "Category: my_mixin;scheme=\"http://example.com/occi/tags#\";class=\"mixin\";location=\"/mixin/my_mixin/\"\n"
        expect(collection.to_text).to eql(expected)
      end

      it 'renders text correctly, actions only' do
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#restart"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#stop"
        expected = "Category: start;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\"\nCategory: restart;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\"\nCategory: stop;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\"\n"
        expect(collection.to_text).to eql(expected)
      end

      it 'renders text correctly, action instance only' do
        action = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action'
        collection.action = Occi::Core::ActionInstance.new action
        expected = "Category: testaction;scheme=\"http://schemas.ogf.org/occi/core/entity/action#\";class=\"action\""
        expect(collection.to_text).to eql(expected)
      end

      it 'renders text correctly, resources only' do
        collection.resources << Occi::Core::Resource.new
        expected = "Category: resource;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/resource/\";title=\"resource\"\nX-OCCI-Attribute: occi.core.id=\"#{collection.resources.first.id}\""
        expect(collection.to_text).to eql(expected)
      end

      it 'renders text correctly, links only' do
        collection.links << Occi::Core::Link.new
        expected = "Category: link;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/link/\";title=\"link\"\nX-OCCI-Attribute: occi.core.id=\"#{collection.links.first.id}\""
        expect(collection.to_text).to eql(expected)
      end

    end

    context '#to_header' do
      let(:collection){ Occi::Collection.new }
      it 'renders header correctly for a simple collection' do
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.action = Occi::Core::ActionInstance.new
        collection.resources << Occi::Core::Resource.new
        collection.links << Occi::Core::Link.new

        expected=Hashie::Mash.new
        expected["Category"] = "compute;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";title=\"compute resource\";rel=\"http://schemas.ogf.org/occi/core#resource\";location=\"/compute/\";attributes=\"occi.core.id{immutable required} occi.core.title occi.core.summary occi.compute.architecture occi.compute.cores occi.compute.hostname occi.compute.memory occi.compute.speed occi.compute.state{immutable}\";actions=\"http://schemas.ogf.org/occi/infrastructure/compute/action#start http://schemas.ogf.org/occi/infrastructure/compute/action#stop http://schemas.ogf.org/occi/infrastructure/compute/action#restart http://schemas.ogf.org/occi/infrastructure/compute/action#suspend\",my_mixin;scheme=\"http://example.com/occi/tags#\";class=\"mixin\";location=\"/mixin/my_mixin/\",start;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\",resource;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/resource/\";title=\"resource\",action_instance;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""
        expected["Link"] = "<>;rel=\"http://schemas.ogf.org/occi/core#link\";self=\"/link/#{collection.links.first.id}\";category=\"http://schemas.ogf.org/occi/core#link\";occi.core.id=\"#{collection.links.first.id}\""
        expected["X-OCCI-Attribute"] = "occi.core.id=\"#{collection.resources.first.id}\""
        expect(collection.to_header).to eql(expected)
      end

      it 'renders text correctly for an empty collection' do
        expected=Hashie::Mash.new
        expect(collection.to_header).to eql(expected)
      end

      it 'renders text correctly, kinds only' do
        collection.kinds << "http://schemas.ogf.org/occi/infrastructure#compute"
        expected=Hashie::Mash.new
        expected["Category"] = "compute;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";title=\"compute resource\";rel=\"http://schemas.ogf.org/occi/core#resource\";location=\"/compute/\";attributes=\"occi.core.id{immutable required} occi.core.title occi.core.summary occi.compute.architecture occi.compute.cores occi.compute.hostname occi.compute.memory occi.compute.speed occi.compute.state{immutable}\";actions=\"http://schemas.ogf.org/occi/infrastructure/compute/action#start http://schemas.ogf.org/occi/infrastructure/compute/action#stop http://schemas.ogf.org/occi/infrastructure/compute/action#restart http://schemas.ogf.org/occi/infrastructure/compute/action#suspend\""
        expect(collection.to_header).to eql(expected)
      end

      it 'renders text correctly, mixins only' do
        collection.mixins << "http://example.com/occi/tags#my_mixin"
        expected=Hashie::Mash.new
        expected["Category"] = "my_mixin;scheme=\"http://example.com/occi/tags#\";class=\"mixin\";location=\"/mixin/my_mixin/\""
        expect(collection.to_header).to eql(expected)
      end

      it 'renders text correctly, actions only' do
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#start"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#restart"
        collection.actions << "http://schemas.ogf.org/occi/infrastructure/compute/action#stop"
        expected=Hashie::Mash.new
        expected["Category"] = "start;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\",restart;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\",stop;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\""
        expect(collection.to_header).to eql(expected)
      end

      it 'renders text correctly, action instance only' do
        action = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action'
        collection.action = Occi::Core::ActionInstance.new action
        expected=Hashie::Mash.new
        expected["Category"] = "testaction;scheme=\"http://schemas.ogf.org/occi/core/entity/action#\";class=\"action\""
        expect(collection.to_header).to eql(expected)
      end

      it 'renders text correctly, resources only' do
        collection.resources << Occi::Core::Resource.new
        expected=Hashie::Mash.new
        expected["Category"] = "resource;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/resource/\";title=\"resource\""
        expected["X-OCCI-Attribute"] = "occi.core.id=\"#{collection.resources.first.id}\""
        expect(collection.to_header).to eql(expected)
      end

      it 'renders text correctly, links only' do
        collection.links << Occi::Core::Link.new
        expected=Hashie::Mash.new
        expected["Category"] = "link;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/link/\";title=\"link\""
        expected["X-OCCI-Attribute"] = "occi.core.id=\"#{collection.links.first.id}\""
        expect(collection.to_header).to eql(expected)
      end

    end

    context '.header_merge' do
      let(:mash1){ mash1 = Hashie::Mash.new
        mash1['a'] = 'a'
        mash1['b'] = 'b'
        mash1
      }
      let(:second){ second = Hashie::Mash.new
        second['a'] = 'd'
        second['c'] = 'c'
        second
      }
      it 'merges two mashes correctly' do
        Occi::Collection.header_merge(mash1, second)

        expected = Hashie::Mash.new
        expected['a'] = 'a,d'
        expected['b'] = 'b'
        expected['c'] = 'c'
        expect(mash1).to eql expected
      end

      it 'merges two mashes correctly with custom separator' do
        Occi::Collection.header_merge(mash1, second, ' : ')

        expected = Hashie::Mash.new
        expected['a'] = 'a : d'
        expected['b'] = 'b'
        expected['c'] = 'c'
        expect(mash1).to eql expected
      end

    end

  end
end
