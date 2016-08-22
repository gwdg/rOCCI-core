module Occi
  module Core
    describe Entity do
      subject(:ent) { entity }

      let(:attribute_title) { 'occi.core.title' }
      let(:attribute_id) { 'occi.core.id' }

      let(:action) { instance_double('Occi::Core::Action') }
      let(:action2) { instance_double('Occi::Core::Action') }
      let(:actions) { Set.new([action]) }

      let(:mixin) { instance_double('Occi::Core::Mixin') }
      let(:mixin2) { instance_double('Occi::Core::Mixin') }
      let(:mixins) { Set.new([mixin]) }

      let(:attributes) do
        {
          attribute_title => instance_double('Occi::Core::AttributeDefinition'),
          attribute_id    => instance_double('Occi::Core::AttributeDefinition')
        }
      end

      let(:kind) do
        Kind.new(
          term: 'root',
          schema: 'http://test.org/root#',
          title: 'Root kind',
          attributes: attributes
        )
      end

      let(:entity) do
        Entity.new(kind: kind, title: 'my_title')
      end

      before(:example) do
        allow(attributes[attribute_title]).to receive(:default)
        allow(attributes[attribute_id]).to receive(:default)
        allow(mixin).to receive(:attributes).and_return({})
        allow(mixin2).to receive(:attributes).and_return({})
      end

      ENTITY_ATTRS = [:kind, :id, :location, :title, :attributes, :mixins, :actions].freeze

      ENTITY_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has attributes value accessor' do
        expect(ent).to be_kind_of(Helpers::InstanceAttributesAccessor)
        expect(ent).to respond_to(:[])
        expect(ent).to respond_to(:[]=)
        expect(ent).to respond_to(:attribute?)
      end

      it 'has logger' do
        expect(ent).to respond_to(:logger)
        expect(ent.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(ent).to be_kind_of(Helpers::Renderable)
        expect(ent).to respond_to(:render)
      end

      describe '::new' do
        context 'without required arguments' do
          it 'raises error on missing `kind`' do
            expect { Entity.new }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end

        context 'with required arguments' do
          it 'constructs instance' do
            expect { Entity.new(kind: kind) }.not_to raise_error
          end
        end
      end

      describe '#id' do
        it 'redirects to `occi.core.id`' do
          expect(ent).to receive(:[]).with('occi.core.id')
          expect { ent.id }.not_to raise_error
        end
      end

      describe '#id=' do
        it 'redirects to `occi.core.id`' do
          expect(ent).to receive(:[]=).with('occi.core.id', 'adasda')
          expect { ent.id = 'adasda' }.not_to raise_error
        end
      end

      describe '#title' do
        it 'redirects to `occi.core.title`' do
          expect(ent).to receive(:[]).with('occi.core.title')
          expect { ent.title }.not_to raise_error
        end
      end

      describe '#title=' do
        it 'redirects to `occi.core.title`' do
          expect(ent).to receive(:[]=).with('occi.core.title', 'asdasd')
          expect { ent.title = 'asdasd' }.not_to raise_error
        end
      end

      describe '#kind=' do
        context 'without kind' do
          it 'raises error' do
            expect { ent.kind = nil }.to raise_error(Occi::Core::Errors::InstanceValidationError)
          end
        end

        context 'with kind' do
          let(:new_kind) { instance_double('Occi::Core::Kind') }

          before(:example) do
            expect(ent).to receive(:reset_attributes!)
          end

          it 'sets kind' do
            expect { ent.kind = new_kind }.not_to raise_error
            expect(ent.kind).to eq new_kind
          end

          it 'triggers attribute reset' do
            expect { ent.kind = new_kind }.not_to raise_error
          end
        end
      end

      describe '#mixins=' do
        context 'without mixins' do
          it 'raises error' do
            expect { ent.mixins = nil }.to raise_error(Occi::Core::Errors::InstanceValidationError)
          end
        end

        context 'with mixins' do
          let(:new_mixins) { Set.new }

          before(:example) do
            expect(ent).to receive(:reset_added_attributes!)
            expect(ent).to receive(:remove_undef_attributes)
          end

          it 'sets mixins' do
            expect { ent.mixins = new_mixins }.not_to raise_error
            expect(ent.mixins).to eq new_mixins
          end

          it 'triggers attribute reset' do
            expect { ent.mixins = new_mixins }.not_to raise_error
          end
        end
      end

      describe '#<<' do
        let(:action) { Occi::Core::Action.new(term: 'action', schema: 'http://my.test.schema/test#') }
        let(:action2) { Occi::Core::Action.new(term: 'action2', schema: 'http://my.test.schema/test#') }
        let(:actions) { Set.new([action]) }

        let(:mixin) { Occi::Core::Mixin.new(term: 'mixin', schema: 'http://my.test.schema/test#') }
        let(:mixin2) { Occi::Core::Mixin.new(term: 'mixin2', schema: 'http://my.test.schema/test#') }
        let(:mixins) { Set.new([mixin]) }

        context 'with action' do
          before(:example) do
            ent.actions = actions
          end

          context 'assigned to entity' do
            it 'silently ignores' do
              expect(ent.actions.count).to eq 1
              expect(ent.actions).to include(action)
              ent << action
              expect(ent.actions.count).to eq 1
              expect(ent.actions).to include(action)
            end
          end

          context 'not assigned to entity' do
            it 'adds action to entity' do
              expect(ent.actions).not_to be_empty
              ent << action2
              expect(ent.actions).to include(action)
              expect(ent.actions).to include(action2)
            end
          end
        end

        context 'with mixin' do
          before(:example) do
            ent.mixins = mixins
          end

          context 'assigned to entity' do
            it 'silently ignores' do
              expect(ent.mixins.count).to eq 1
              expect(ent.mixins).to include(mixin)
              ent << mixin
              expect(ent.mixins.count).to eq 1
              expect(ent.mixins).to include(mixin)
            end
          end

          context 'not assigned to entity' do
            it 'adds mixin to entity' do
              expect(ent.mixins).not_to be_empty
              ent << mixin2
              expect(ent.mixins).to include(mixin)
              expect(ent.mixins).to include(mixin2)
            end
          end
        end

        context 'with unknown object' do
          it 'raises error' do
            expect { ent << Object.new }.to raise_error(ArgumentError)
          end
        end
      end

      describe '#remove' do
        let(:action) { Occi::Core::Action.new(term: 'action', schema: 'http://my.test.schema/test#') }
        let(:action2) { Occi::Core::Action.new(term: 'action2', schema: 'http://my.test.schema/test#') }
        let(:actions) { Set.new([action]) }

        let(:mixin) { Occi::Core::Mixin.new(term: 'mixin', schema: 'http://my.test.schema/test#') }
        let(:mixin2) { Occi::Core::Mixin.new(term: 'mixin2', schema: 'http://my.test.schema/test#') }
        let(:mixins) { Set.new([mixin]) }

        context 'with action' do
          before(:example) do
            ent.actions = actions
          end

          context 'assigned to entity' do
            it 'removes given action' do
              expect(ent.actions).not_to be_empty
              ent.remove action
              expect(ent.actions).to be_empty
            end
          end

          context 'not assigned to entity' do
            it 'silently ignores' do
              expect(ent.actions).not_to be_empty
              ent.remove action2
              expect(ent.actions).to include(action)
              expect(ent.actions).not_to include(action2)
            end
          end
        end

        context 'with mixin' do
          before(:example) do
            ent.mixins = mixins
          end

          context 'assigned to entity' do
            it 'removes given mixin' do
              expect(ent.mixins).not_to be_empty
              ent.remove mixin
              expect(ent.mixins).to be_empty
            end
          end

          context 'not assigned to entity' do
            it 'silently ignores' do
              expect(ent.mixins).not_to be_empty
              ent.remove mixin2
              expect(ent.mixins).to include(mixin)
              expect(ent.mixins).not_to include(mixin2)
            end
          end
        end

        context 'with unknown object' do
          it 'raises error' do
            expect { ent.remove(Object.new) }.to raise_error(ArgumentError)
          end
        end
      end

      describe '#add_mixin' do
        context 'when mixin is new' do
          it 'adds mixin to mixins' do
            expect(ent.mixins).to be_empty
            expect { ent.add_mixin(mixin) }.not_to raise_error
            expect(ent.mixins).not_to be_empty
          end
        end

        context 'when mixin is already assigned' do
          before(:example) do
            ent.mixins = mixins
          end

          it 'does nothing' do
            expect(ent.mixins).to eq mixins
            expect { ent.add_mixin(mixin) }.not_to raise_error
            expect(ent.mixins).to eq mixins
          end
        end

        context 'when no mixin is provided' do
          it 'fails' do
            expect { ent.add_mixin(nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#remove_mixin' do
        context 'when mixin exists' do
          before(:example) do
            ent.mixins = mixins
          end

          it 'removes mixins from instance' do
            expect { ent.remove_mixin(mixin) }.not_to raise_error
            expect(ent.mixins).to be_empty
          end
        end

        context 'when mixin does not exist' do
          it 'does not raise error' do
            expect { ent.remove_mixin(mixin) }.not_to raise_error
          end
        end

        context 'when no mixin is provided' do
          it 'fails' do
            expect { ent.remove_mixin(nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#replace_mixin' do
        context 'when mixin exists' do
          before(:example) do
            ent.mixins = mixins
          end

          it 'replaces mixin' do
            expect(ent.mixins).to include(mixin)
            expect { ent.replace_mixin(mixin, mixin2) }.not_to raise_error
            expect(ent.mixins).to include(mixin2)
            expect(ent.mixins).not_to include(mixin)
          end
        end

        context 'when mixin does not exist' do
          it 'does not change anything' do
            expect(ent.mixins).to be_empty
            expect { ent.replace_mixin(mixin, mixin2) }.not_to raise_error
            expect(ent.mixins).to include(mixin2)
          end
        end

        context 'when no mixin is provided' do
          it 'fails' do
            expect { ent.replace_mixin(nil, nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#add_action' do
        context 'when action is new' do
          it 'adds action to actions' do
            expect(ent.actions).to be_empty
            expect { ent.add_action(action) }.not_to raise_error
            expect(ent.actions).not_to be_empty
          end
        end

        context 'when action is already assigned' do
          before(:example) do
            ent.actions = actions
          end

          it 'does nothing' do
            expect(ent.actions).to eq actions
            expect { ent.add_action(action) }.not_to raise_error
            expect(ent.actions).to eq actions
          end
        end

        context 'when no action is provided' do
          it 'fails' do
            expect { ent.add_action(nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#remove_action' do
        context 'when action exists' do
          before(:example) do
            ent.actions = actions
          end

          it 'removes actions from instance' do
            expect { ent.remove_action(action) }.not_to raise_error
            expect(ent.actions).to be_empty
          end
        end

        context 'when action does not exist' do
          it 'does not raise error' do
            expect { ent.remove_action(action) }.not_to raise_error
          end
        end

        context 'when no action is provided' do
          it 'fails' do
            expect { ent.remove_action(nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#valid?' do
        context 'on failure' do
          it 'returns false' do
            expect(ent).to receive(:valid!).and_raise(Occi::Core::Errors::InstanceValidationError)
            expect(ent.valid?).to be false
          end
        end

        context 'on success' do
          it 'returns true' do
            expect(ent).to receive(:valid!)
            expect(ent.valid?).to be true
          end
        end
      end

      describe '#valid!' do
        context 'with missing required attributes' do
          before(:example) { ent.id = nil }

          it 'raises error' do
            expect { ent.valid! }.to raise_error(Occi::Core::Errors::InstanceValidationError)
          end
        end

        context 'with all required attributes' do
          before(:example) do
            attributes.values.each { |v| expect(v).to receive(:valid!) }
          end

          it 'passes without error' do
            expect { ent.valid! }.not_to raise_error
          end
        end
      end

      describe '#base_attributes' do
        it 'returns attributes from kind' do
          expect(ent.base_attributes).to eq kind.attributes
        end
      end

      describe '#added_attributes' do
        context 'with mixin(s)' do
          before(:example) do
            allow(ent).to receive(:mixins).and_return(mixins)
            allow(mixin).to receive(:attributes).and_return(attributes)
          end

          it 'returns list of attributes from mixins' do
            expect(ent.added_attributes).to eq [attributes]
          end
        end

        context 'without mixin(s)' do
          it 'returns empty list' do
            expect(ent.added_attributes).to be_empty
            expect(ent.added_attributes).to be_kind_of Array
          end
        end
      end
    end
  end
end
