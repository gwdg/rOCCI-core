module Occi
  module Core
    describe Collection do
      subject(:coll) { collection }
      let(:collection) { Collection.new }

      let(:kind) { instance_double('Occi::Core::Kind') }
      let(:mixin) { instance_double('Occi::Core::Mixin') }
      let(:action) { instance_double('Occi::Core::Action') }
      let(:resource) { instance_double('Occi::Core::Resource') }
      let(:link) { instance_double('Occi::Core::Link') }
      let(:action_instance) { instance_double('Occi::Core::ActionInstance') }

      let(:all) { Set.new([kind, mixin, action, resource, link, action_instance]) }
      let(:categories) { Set.new([kind, mixin, action]) }
      let(:entities) { Set.new([resource, link]) }
      let(:action_instances) { Set.new([action_instance]) }

      COLL_ATTRS = [:categories, :entities, :action_instances].freeze

      COLL_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has logger' do
        expect(coll).to respond_to(:logger)
        expect(coll.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(coll).to be_kind_of(Helpers::Renderable)
        expect(coll).to respond_to(:render)
      end

      before do
        coll.categories = categories
        coll.entities = entities
        coll.action_instances = action_instances

        [:kind, :mixin, :action, :resource, :link].each do |elm|
          allow(send(elm)).to receive(:is_a?).with(Class).and_return(false)
          allow(send(elm)).to receive(:is_a?).with(Occi::Core.const_get(elm.to_s.capitalize)).and_return(true)
        end

        allow(resource).to receive(:kind).and_return(kind)
        allow(resource).to receive(:mixins).and_return(Set.new([mixin]))
        allow(link).to receive(:kind).and_return(kind)
        allow(link).to receive(:mixins).and_return(Set.new([mixin]))
        allow(action_instance).to receive(:action).and_return(action)
      end

      describe '#all' do
        it 'returns everything' do
          expect(coll.all).to eq all
        end
      end

      describe '#kinds' do
        let(:kinds) { Set.new([kind]) }

        it 'returns only kinds' do
          expect(coll.kinds).to eq kinds
        end
      end

      describe '#mixins' do
        let(:mixins) { Set.new([mixin]) }

        it 'returns only mixins' do
          expect(coll.mixins).to eq mixins
        end
      end

      describe '#actions' do
        let(:actions) { Set.new([action]) }

        it 'returns only actions' do
          expect(coll.actions).to eq actions
        end
      end

      describe '#resources' do
        let(:resources) { Set.new([resource]) }

        it 'returns only resources' do
          expect(coll.resources).to eq resources
        end
      end

      describe '#links' do
        let(:links) { Set.new([link]) }

        it 'returns only links' do
          expect(coll.links).to eq links
        end
      end

      describe '#find_related' do
        context 'without kind' do
          it 'raises error' do
            expect { coll.find_related(nil) }.to raise_error(ArgumentError)
          end
        end

        context 'with kind' do
          let(:sample_kind) { instance_double('Occi::Core::Kind') }

          it 'returns set of kinds by default' do
            expect(kind).to receive(:related?).with(sample_kind).and_return(true)
            expect(coll.find_related(sample_kind)).to eq Set.new([kind])
          end

          it 'returns set of directly related kinds' do
            expect(kind).to receive(:directly_related?).with(sample_kind).and_return(true)
            expect(coll.find_related(sample_kind, directly: true)).to eq Set.new([kind])
          end
        end
      end

      describe '#find_dependent' do
        context 'without mixin' do
          it 'raises error' do
            expect { coll.find_dependent(nil) }.to raise_error(ArgumentError)
          end
        end

        context 'with mixin' do
          let(:sample_mixin) { instance_double('Occi::Core::Mixin') }

          it 'returns set of mixins' do
            expect(mixin).to receive(:depends?).with(sample_mixin).and_return(true)
            expect(coll.find_dependent(sample_mixin)).to eq Set.new([mixin])
          end
        end
      end

      describe '#find_by_location' do
        before do
          [:kind, :mixin, :resource, :link].each do |elm|
            allow(send(elm)).to receive(:location).and_return(fake_location)
          end
        end

        let(:fake_location) { URI.parse('/fake/location/') }
        let(:locatable) { Set.new([kind, mixin, resource, link]) }

        it 'returns set of instances with matching location' do
          expect(coll.find_by_location(fake_location)).to eq locatable
        end
      end

      describe '#find_by_kind' do
        context 'without kind' do
          it 'raises error' do
            expect { coll.find_by_kind(nil) }.to raise_error(ArgumentError)
          end
        end

        context 'with kind' do
          let(:sample_kind) { instance_double('Occi::Core::Kind') }

          it 'returns set of entities with the given kind' do
            expect(resource).to receive(:kind).and_return(sample_kind)
            expect(link).to receive(:kind).and_return(sample_kind)
            expect(coll.find_by_kind(sample_kind)).to eq Set.new([resource, link])
          end
        end
      end

      describe '#find_by_action' do
        context 'without action' do
          it 'raises error' do
            expect { coll.find_by_action(nil) }.to raise_error(ArgumentError)
          end
        end

        context 'with action' do
          let(:sample_action) { instance_double('Occi::Core::Action') }

          it 'returns set of AIs with the given action' do
            expect(action_instance).to receive(:action).and_return(sample_action)
            expect(coll.find_by_action(sample_action)).to eq action_instances
          end
        end
      end

      describe '#find_by_mixin' do
        context 'without mixin' do
          it 'raises error' do
            expect { coll.find_by_mixin(nil) }.to raise_error(ArgumentError)
          end
        end

        context 'with mixin' do
          let(:sample_mixin) { instance_double('Occi::Core::Mixin') }

          it 'returns set of entities with the given mixin' do
            expect(resource).to receive(:mixins).and_return(Set.new([sample_mixin]))
            expect(link).to receive(:mixins).and_return(Set.new([sample_mixin]))
            expect(coll.find_by_mixin(sample_mixin)).to eq Set.new([resource, link])
          end
        end
      end

      describe '#find_by_id' do
        let(:sample_id) { '64654f-6a5df4a6-df46ad4f' }

        it 'returns set of entities with the given occi.core.id' do
          expect(resource).to receive(:id).and_return(sample_id)
          expect(link).to receive(:id).and_return(sample_id)
          expect(coll.find_by_id(sample_id)).to eq Set.new([resource, link])
        end
      end

      describe '#find_by_identifier' do
        let(:sample_identifier) { 'http://my.schema.com/test#shutup' }

        it 'returns set of categories with the given identifier' do
          categories.each { |cat| expect(cat).to receive(:identifier).and_return(sample_identifier) }
          expect(coll.find_by_identifier(sample_identifier)).to eq categories
        end
      end

      describe '#find_by_term' do
        let(:sample_term) { 'shutup' }

        it 'returns set of categories with the given term' do
          categories.each { |cat| expect(cat).to receive(:term).and_return(sample_term) }
          expect(coll.find_by_term(sample_term)).to eq categories
        end
      end

      describe '#find_by_schema' do
        let(:sample_schema) { 'http://my.schema.com/test#' }

        it 'returns set of categories with the given schema' do
          categories.each { |cat| expect(cat).to receive(:schema).and_return(sample_schema) }
          expect(coll.find_by_schema(sample_schema)).to eq categories
        end
      end

      describe '#<<' do
        context 'with category' do
          before do
            coll.categories = Set.new
          end

          let(:kind) { Occi::Core::Kind.new(term: 'kind', schema: 'http://my.test.com/new#') }
          let(:mixin) { Occi::Core::Mixin.new(term: 'mixin', schema: 'http://my.test.com/new#') }
          let(:action) { Occi::Core::Action.new(term: 'action', schema: 'http://my.test.com/new#') }
          let(:categories) { Set.new([kind, mixin, action]) }

          it 'assigns to categories' do
            expect(coll.categories).to be_empty
            expect { coll << kind }.not_to raise_error
            expect { coll << mixin }.not_to raise_error
            expect { coll << action }.not_to raise_error
            expect(coll.categories).to eq categories
          end
        end

        context 'with entity' do
          before do
            coll.entities = Set.new
          end

          let(:kind) { Occi::Core::Kind.new(term: 'kind', schema: 'http://my.test.com/new#') }
          let(:resource) { Occi::Core::Resource.new(kind: kind, title: 'My Resource') }
          let(:link) { Occi::Core::Link.new(kind: kind, title: 'My Link') }
          let(:entities) { Set.new([resource, link]) }

          it 'assigns to entities' do
            expect(coll.entities).to be_empty
            expect { coll << resource }.not_to raise_error
            expect { coll << link }.not_to raise_error
            expect(coll.entities).to eq entities
          end
        end

        context 'with action instance' do
          before do
            coll.action_instances = Set.new
          end

          let(:action) { Occi::Core::Action.new(term: 'action', schema: 'http://my.test.com/new#') }
          let(:action_instance) { Occi::Core::ActionInstance.new(action: action) }
          let(:action_instances) { Set.new([action_instance]) }

          it 'assigns to action_instances' do
            expect(coll.action_instances).to be_empty
            expect { coll << action_instance }.not_to raise_error
            expect(coll.action_instances).to eq action_instances
          end
        end

        context 'with unknown object' do
          it 'raises error' do
            expect { coll << Object.new }.to raise_error(ArgumentError)
          end
        end
      end

      describe '#remove' do
        context 'with category' do
          before do
            coll.categories = categories
          end

          let(:kind) { Occi::Core::Kind.new(term: 'kind', schema: 'http://my.test.com/new#') }
          let(:mixin) { Occi::Core::Mixin.new(term: 'mixin', schema: 'http://my.test.com/new#') }
          let(:action) { Occi::Core::Action.new(term: 'action', schema: 'http://my.test.com/new#') }
          let(:categories) { Set.new([kind, mixin, action]) }

          it 'assigns to categories' do
            expect(coll.categories).to eq categories
            expect { coll.remove(kind) }.not_to raise_error
            expect { coll.remove(mixin) }.not_to raise_error
            expect { coll.remove(action) }.not_to raise_error
            expect(coll.categories).to be_empty
          end
        end

        context 'with entity' do
          before do
            coll.entities = entities
          end

          let(:kind) { Occi::Core::Kind.new(term: 'kind', schema: 'http://my.test.com/new#') }
          let(:resource) { Occi::Core::Resource.new(kind: kind, title: 'My Resource') }
          let(:link) { Occi::Core::Link.new(kind: kind, title: 'My Link') }
          let(:entities) { Set.new([resource, link]) }

          it 'assigns to entities' do
            expect(coll.entities).to eq entities
            expect { coll.remove(resource) }.not_to raise_error
            expect { coll.remove(link) }.not_to raise_error
            expect(coll.entities).to be_empty
          end
        end

        context 'with action instance' do
          before do
            coll.action_instances = action_instances
          end

          let(:action) { Occi::Core::Action.new(term: 'action', schema: 'http://my.test.com/new#') }
          let(:action_instance) { Occi::Core::ActionInstance.new(action: action) }
          let(:action_instances) { Set.new([action_instance]) }

          it 'assigns to action_instances' do
            expect(coll.action_instances).to eq action_instances
            expect { coll.remove(action_instance) }.not_to raise_error
            expect(coll.action_instances).to be_empty
          end
        end

        context 'with unknown object' do
          it 'raises error' do
            expect { coll.remove(Object.new) }.to raise_error(ArgumentError)
          end
        end
      end

      describe '#valid?' do
        context 'with valid instances' do
          before do
            expect(resource).to receive(:valid?).and_return(true)
            expect(link).to receive(:valid?).and_return(true)
            expect(action_instance).to receive(:valid?).and_return(true)
          end

          it 'calls `valid?` on entities and action instances' do
            expect(coll.valid?).to be true
          end
        end

        context 'with invalid instances' do
          before do
            allow(resource).to receive(:valid?).and_return(false)
            allow(link).to receive(:valid?).and_return(false)
            allow(action_instance).to receive(:valid?).and_return(false)
          end

          it 'calls `valid?` on entities and action instances' do
            expect(coll.valid?).to be false
          end
        end
      end

      describe '#valid!' do
        context 'with valid instances' do
          before do
            expect(resource).to receive(:valid!)
            expect(link).to receive(:valid!)
            expect(action_instance).to receive(:valid!)
          end

          it 'calls `valid!` on entities and action instances' do
            expect { coll.valid! }.not_to raise_error
          end
        end

        context 'with invalid instances' do
          before do
            allow(resource).to receive(:valid!).and_raise(Occi::Core::Errors::ValidationError)
            allow(link).to receive(:valid!).and_raise(Occi::Core::Errors::ValidationError)
            allow(action_instance).to receive(:valid!).and_raise(Occi::Core::Errors::ValidationError)
          end

          it 'calls `valid!` on entities and action instances' do
            expect { coll.valid! }.to raise_error(Occi::Core::Errors::ValidationError)
          end
        end
      end
    end
  end
end
