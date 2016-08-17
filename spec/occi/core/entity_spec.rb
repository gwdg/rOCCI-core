module Occi
  module Core
    describe Entity do
      subject { entity }

      let(:attribute_title) { 'occi.core.title' }
      let(:attribute_id) { 'occi.core.id' }

      let(:action) { instance_double('Occi::Core::Action') }
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
        expect(subject).to be_kind_of(Helpers::InstanceAttributesAccessor)
        expect(subject).to respond_to(:[])
        expect(subject).to respond_to(:[]=)
        expect(subject).to respond_to(:attribute?)
      end

      it 'has logger' do
        expect(subject).to respond_to(:logger)
        expect(subject.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(subject).to be_kind_of(Helpers::Renderable)
        expect(subject).to respond_to(:render)
      end

      describe '::new'

      describe '#id'
      describe '#id='
      describe '#title'
      describe '#title='
      describe '#kind='
      describe '#mixins='

      describe '#<<'
      describe '#remove'

      describe '#add_mixin' do
        context 'when mixin is new' do
          it 'adds mixin to mixins' do
            expect(subject.mixins).to be_empty
            expect { subject.add_mixin(mixin) }.not_to raise_error
            expect(subject.mixins).not_to be_empty
          end
        end

        context 'when mixin is already assigned' do
          before(:example) do
            subject.mixins = mixins
          end

          it 'does nothing' do
            expect(subject.mixins).to eq mixins
            expect { subject.add_mixin(mixin) }.not_to raise_error
            expect(subject.mixins).to eq mixins
          end
        end

        context 'when no mixin is provided' do
          it 'fails' do
            expect { subject.add_mixin(nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#remove_mixin' do
        context 'when mixin exists' do
          before(:example) do
            subject.mixins = mixins
          end

          it 'removes mixins from instance' do
            expect { subject.remove_mixin(mixin) }.not_to raise_error
            expect(subject.mixins).to be_empty
          end
        end

        context 'when mixin does not exist' do
          it 'does not raise error' do
            expect { subject.remove_mixin(mixin) }.not_to raise_error
          end
        end

        context 'when no mixin is provided' do
          it 'fails' do
            expect { subject.remove_mixin(nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#replace_mixin' do
        context 'when mixin exists' do
          before(:example) do
            subject.mixins = mixins
          end

          it 'replaces mixin' # do
          #   expect(subject.mixins).to include(mixin)
          #   expect { subject.replace_mixin(mixin, mixin2) }
          #   expect(subject.mixins).to include(mixin2)
          #   expect(subject.mixins).not_to include(mixin)
          # end
        end

        context 'when mixin does not exist' do
          it 'does not change anything' do
            expect(subject.mixins).to be_empty
            expect { subject.replace_mixin(mixin, mixin2) }.not_to raise_error
            expect(subject.mixins).to include(mixin2)
          end
        end

        context 'when no mixin is provided' do
          it 'fails' do
            expect { subject.replace_mixin(nil, nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#add_action' do
        context 'when action is new' do
          it 'adds action to actions' do
            expect(subject.actions).to be_empty
            expect { subject.add_action(action) }.not_to raise_error
            expect(subject.actions).not_to be_empty
          end
        end

        context 'when action is already assigned' do
          before(:example) do
            subject.actions = actions
          end

          it 'does nothing' do
            expect(subject.actions).to eq actions
            expect { subject.add_action(action) }.not_to raise_error
            expect(subject.actions).to eq actions
          end
        end

        context 'when no action is provided' do
          it 'fails' do
            expect { subject.add_action(nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#remove_action' do
        context 'when action exists' do
          before(:example) do
            subject.actions = actions
          end

          it 'removes actions from instance' do
            expect { subject.remove_action(action) }.not_to raise_error
            expect(subject.actions).to be_empty
          end
        end

        context 'when action does not exist' do
          it 'does not raise error' do
            expect { subject.remove_action(action) }.not_to raise_error
          end
        end

        context 'when no action is provided' do
          it 'fails' do
            expect { subject.remove_action(nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end
      end

      describe '#valid?' do
        context 'on failure' do
          it 'returns false' do
            expect(subject).to receive(:valid!).and_raise(Occi::Core::Errors::InstanceValidationError)
            expect(subject.valid?).to be false
          end
        end

        context 'on success' do
          it 'returns true' do
            expect(subject).to receive(:valid!)
            expect(subject.valid?).to be true
          end
        end
      end

      describe '#valid!' do
        context 'with missing required attributes' do
          before(:example) { subject.id = nil }

          it 'raises error' do
            expect { subject.valid! }.to raise_error(Occi::Core::Errors::InstanceValidationError)
          end
        end

        context 'with all required attributes' do
          before(:example) do
            attributes.values.each { |v| expect(v).to receive(:valid!) }
          end

          it 'passes without error' do
            expect { subject.valid! }.not_to raise_error
          end
        end
      end

      describe '#base_attributes' do
        it 'returns attributes from kind' do
          expect(subject.base_attributes).to eq kind.attributes
        end
      end

      describe '#added_attributes' do
        context 'with mixin(s)' do
          before(:example) do
            allow(subject).to receive(:mixins).and_return(mixins)
            allow(mixin).to receive(:attributes).and_return(attributes)
          end

          it 'returns list of attributes from mixins' do
            expect(subject.added_attributes).to eq [attributes]
          end
        end

        context 'without mixin(s)' do
          it 'returns empty list' do
            expect(subject.added_attributes).to be_empty
            expect(subject.added_attributes).to be_kind_of Array
          end
        end
      end
    end
  end
end
