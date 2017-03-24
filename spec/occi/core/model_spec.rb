module Occi
  module Core
    describe Model do
      subject(:mdl) { model }

      let(:model) { Model.new }

      let(:example_term) { 'kind' }
      let(:example_schema) { 'http://schemas.org/schema#' }
      let(:example_title) { 'Generic kind' }

      let(:attribute_title) { 'occi.core.title' }
      let(:attribute_id) { 'occi.core.id' }
      let(:attribute_source) { 'occi.core.source' }
      let(:attribute_target) { 'occi.core.target' }
      let(:attributes) do
        {
          attribute_title   => instance_double('Occi::Core::AttributeDefinition'),
          attribute_id      => instance_double('Occi::Core::AttributeDefinition'),
          attribute_source  => instance_double('Occi::Core::AttributeDefinition'),
          attribute_target  => instance_double('Occi::Core::AttributeDefinition')
        }
      end

      let(:root_kind) do
        Kind.new(
          term: 'root',
          schema: 'http://test.org/root#',
          title: 'Root kind'
        )
      end

      let(:kind) do
        Kind.new(
          term: example_term,
          schema: example_schema,
          title: example_title,
          parent: root_kind,
          attributes: attributes
        )
      end

      let(:mixin) do
        Mixin.new(
          term: 'mixin',
          schema: example_schema,
          title: 'Mixin',
          applies: [kind]
        )
      end

      let(:action) do
        Action.new(
          schema: example_schema,
          term: 'action',
          title: 'Action'
        )
      end

      let(:all) { Set.new([root_kind, kind, mixin, action]) }

      before do
        attributes.keys.each do |attrib|
          allow(attributes[attrib]).to receive(:default)
          allow(attributes[attrib]).to receive(:valid!)
        end

        mdl << kind << action << mixin << root_kind
      end

      it 'has logger' do
        expect(mdl).to respond_to(:logger)
        expect(mdl.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(mdl).to be_kind_of(Helpers::Renderable)
        expect(mdl).to respond_to(:render)
      end

      describe '#all' do
        it 'returns everything' do
          expect(model.all).to eq all
        end
      end

      describe '#kinds' do
        let(:kinds) { Set.new([root_kind, kind]) }

        it 'returns only kinds' do
          expect(model.kinds).to eq kinds
        end
      end

      describe '#mixins' do
        let(:mixins) { Set.new([mixin]) }

        it 'returns only mixins' do
          expect(model.mixins).to eq mixins
        end
      end

      describe '#actions' do
        let(:actions) { Set.new([action]) }

        it 'returns only actions' do
          expect(model.actions).to eq actions
        end
      end

      describe '#parent_kinds' do
        context 'with some parents' do
          it 'returns `root_kind`' do
            expect(model.parent_kinds).to eq Set.new([root_kind])
          end
        end

        context 'without parents' do
          before { kind.parent = nil }

          it 'returns empty set' do
            expect(model.parent_kinds).to be_empty
          end
        end
      end

      describe '#depended_on_mixins' do
        context 'with some depended-on mixins' do
          let(:root_mixin) do
            Mixin.new(
              term: 'root_mixin',
              schema: example_schema,
              title: 'Root Mixin',
              applies: [kind]
            )
          end

          before { mixin.depends << root_mixin }

          it 'returns `depended-on` mixins' do
            expect(model.depended_on_mixins).to eq Set.new([root_mixin])
          end
        end

        context 'with no depended-on mixins' do
          it 'returns empty set' do
            expect(model.depended_on_mixins).to be_empty
          end
        end
      end

      describe '#associated_actions' do
        context 'with some associated actions' do
          before { kind.actions << action }

          it 'returns associated actions' do
            expect(model.associated_actions).to eq Set.new([action])
          end
        end

        context 'with no associated actions' do
          it 'returns empty set' do
            expect(model.associated_actions).to be_empty
          end
        end
      end

      describe '#find_related' do
        context 'without kind' do
          it 'raises error' do
            expect { model.find_related(nil) }.to raise_error(ArgumentError)
          end
        end

        context 'with kind' do
          let(:sample_kind) { instance_double('Occi::Core::Kind') }

          it 'returns set of kinds by default' do
            expect(kind).to receive(:related?).with(sample_kind).and_return(true)
            expect(model.find_related(sample_kind)).to eq Set.new([kind])
          end

          it 'returns set of directly related kinds' do
            expect(kind).to receive(:directly_related?).with(sample_kind).and_return(true)
            expect(model.find_related(sample_kind, directly: true)).to eq Set.new([kind])
          end

          it 'returns empty set when nothing is related' do
            expect(kind).to receive(:related?).with(sample_kind).and_return(false)
            expect(model.find_related(sample_kind)).to be_empty
          end

          it 'returns empty set when nothing is directly related' do
            expect(kind).to receive(:directly_related?).with(sample_kind).and_return(false)
            expect(model.find_related(sample_kind, directly: true)).to be_empty
          end
        end
      end

      describe '#find_dependent' do
        context 'without mixin' do
          it 'raises error' do
            expect { model.find_dependent(nil) }.to raise_error(ArgumentError)
          end
        end

        context 'with mixin' do
          let(:sample_mixin) { instance_double('Occi::Core::Mixin') }

          it 'returns set of mixins' do
            expect(mixin).to receive(:depends?).with(sample_mixin).and_return(true)
            expect(model.find_dependent(sample_mixin)).to eq Set.new([mixin])
          end

          it 'returns empty set when nothing depends' do
            expect(mixin).to receive(:depends?).with(sample_mixin).and_return(false)
            expect(model.find_dependent(sample_mixin)).to be_empty
          end
        end
      end

      describe '#find_by_identifier' do
        let(:sample_identifier) { 'http://definitely.not/there#yaas' }

        it 'returns set of categories with the given identifier' do
          expect(model.find_by_identifier(example_schema + example_term)).to eq Set.new([kind])
        end

        it 'returns empty set when no identifier matches' do
          expect(model.find_by_identifier(sample_identifier)).to be_empty
        end
      end

      describe '#find_by_term' do
        let(:sample_term) { 'yaas' }

        it 'returns set of categories with the given term' do
          expect(model.find_by_term(example_term)).to eq Set.new([kind])
        end

        it 'returns empty set when no term matches' do
          expect(model.find_by_term(sample_term)).to be_empty
        end
      end

      describe '#find_by_schema' do
        let(:sample_schema) { 'http://definitely.not/there#' }

        it 'returns set of categories with the given schema' do
          expect(model.find_by_schema(example_schema)).to eq Set.new([kind, mixin, action])
        end

        it 'returns empty set when no scheme matches' do
          expect(model.find_by_schema(sample_schema)).to be_empty
        end
      end

      describe '#valid!' do
        context 'on valid model' do
          it 'does not raise error' do
            expect { model.valid! }.not_to raise_error
          end
        end

        context 'on invalid model' do
          before { model.remove root_kind }

          it 'raises validation error' do
            expect { model.valid! }.to raise_error(Occi::Core::Errors::CategoryValidationError)
          end
        end
      end

      describe '#valid?' do
        context 'on valid model' do
          it 'returns `true`' do
            expect(model.valid?).to be true
          end
        end

        context 'on invalid model' do
          before { model.remove root_kind }

          it 'returns `false`' do
            expect(model.valid?).to be false
          end
        end
      end

      describe '#empty?' do
        context 'with some categories' do
          it 'returns `false`' do
            expect(model.empty?).to be false
          end
        end

        context 'with no categories' do
          before { model.categories = Set.new }

          it 'return `true`' do
            expect(model.empty?).to be true
          end
        end
      end
    end
  end
end
