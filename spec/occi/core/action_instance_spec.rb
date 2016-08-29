module Occi
  module Core
    describe ActionInstance do
      subject(:ai) { action_instance }

      let(:action) { instance_double('Occi::Core::Action') }
      let(:action_attributes) { { 'method' => instance_double('Occi::Core::AttributeDefinition') } }
      let(:attributes) { { 'method' => instance_double('Occi::Core::Attribute') } }
      let(:action_instance) { ActionInstance.new(action: action, attributes: attributes) }

      context '' do
        before(:example) do
          allow(action).to receive(:attributes).and_return({})
        end

        AI_ATTRS = [:action, :attributes].freeze

        AI_ATTRS.each do |attr|
          it "has #{attr} accessor" do
            is_expected.to have_attr_accessor attr.to_sym
          end
        end

        it 'has logger' do
          expect(ai).to respond_to(:logger)
          expect(ai.class).to respond_to(:logger)
        end

        it 'is renderable' do
          expect(ai).to be_kind_of(Helpers::Renderable)
          expect(ai).to respond_to(:render)
        end

        it 'has attributes value accessor' do
          expect(ai).to be_kind_of(Helpers::InstanceAttributesAccessor)
          expect(ai).to respond_to(:[])
          expect(ai).to respond_to(:[]=)
          expect(ai).to respond_to(:attribute?)
        end
      end

      describe '#new' do
        it 'raises error when action not provided' do
          expect do
            ActionInstance.new(action: nil, attributes: {})
          end.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
        end
      end

      describe '#action_identifier' do
        before(:example) do
          allow(action).to receive(:attributes).and_return({})
        end

        it 'returns action identifier' do
          expect(action).to receive(:identifier).and_return('http://test.org/root#root')
          expect(ai.action_identifier).to eq 'http://test.org/root#root'
        end
      end

      describe '#valid?' do
        before(:example) do
          allow(action).to receive(:attributes).and_return(action_attributes)
          allow(attributes['method']).to receive(:attribute_definition=).with(action_attributes['method'])
          allow(attributes['method']).to receive(:attribute_definition).and_return(action_attributes['method'])
          allow(attributes['method']).to receive(:default)
        end

        it 'returns `true` when action and attributes valid' do
          expect(attributes['method']).to receive(:valid!)
          expect(ai.valid?).to be true
        end

        it 'returns `false` when attributes missing' do
          ai.attributes = nil
          expect(ai.valid?).to be false
        end

        it 'returns `false` when attribute is invalid' do
          expect(ai.attributes['method']).to receive(:valid!).and_raise(
            Occi::Core::Errors::AttributeValidationError
          )
          expect(ai.valid?).to be false
        end
      end

      describe '#valid!' do
        before(:example) do
          allow(action).to receive(:attributes).and_return(action_attributes)
          allow(attributes['method']).to receive(:attribute_definition=).with(action_attributes['method'])
          allow(attributes['method']).to receive(:attribute_definition).and_return(action_attributes['method'])
          allow(attributes['method']).to receive(:default)
        end

        it 'does not raise error when action and attributes valid' do
          expect(ai.attributes['method']).to receive(:valid!)
          expect { ai.valid! }.not_to raise_error
        end

        it 'raises error when attributes missing' do
          ai.attributes = nil
          expect { ai.valid! }.to raise_error(Occi::Core::Errors::InstanceValidationError)
        end

        it 'raises error when attribute is invalid' do
          expect(ai.attributes['method']).to receive(:valid!).and_raise(
            Occi::Core::Errors::AttributeValidationError
          )
          expect { ai.valid! }.to raise_error(Occi::Core::Errors::AttributeValidationError)
        end
      end

      describe '#action=' do
        before(:example) do
          allow(action).to receive(:attributes).and_return(action_attributes)
          allow(attributes['method']).to receive(:attribute_definition=).with(action_attributes['method'])
          allow(attributes['method']).to receive(:attribute_definition).and_return(action_attributes['method'])
          allow(attributes['method']).to receive(:default!)
          allow(attributes['method']).to receive(:default)
        end

        it 'assigns new action to instance' do
          expect { ai.action = action }.not_to raise_error
        end
      end
    end
  end
end
