module Occi
  module Core
    describe ActionInstance do
      subject { action_instance }

      let(:action) { instance_double('Occi::Core::Action') }
      let(:attributes) { { 'method' => instance_double('Occi::Core::Attribute') } }
      let(:action_instance) { ActionInstance.new(action: action, attributes: attributes) }

      AI_ATTRS = [:action, :attributes].freeze

      AI_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          expect(action).to receive(:attributes).and_return({})
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has logger' do
        expect(action).to receive(:attributes).and_return({})
        expect(subject).to respond_to(:logger)
        expect(subject.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(action).to receive(:attributes).and_return({})
        expect(subject).to be_kind_of(Helpers::Renderable)
        expect(subject).to respond_to(:render)
      end

      it 'has attributes value accessor' do
        expect(action).to receive(:attributes).and_return({})
        expect(subject).to be_kind_of(Helpers::InstanceAttributesAccessor)
        expect(subject).to respond_to(:[])
        expect(subject).to respond_to(:[]=)
        expect(subject).to respond_to(:attribute?)
      end

      describe '#new' do
        it 'raises error when action not provided' do
          expect { ActionInstance.new(action: nil, attributes: {}) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
        end
      end

      describe '#valid?' do
        it 'returns `true` when action and attributes valid' do
          expect(action).to receive(:attributes).and_return({})
          expect(subject.attributes['method']).to receive(:valid!)
          expect(subject.valid?).to be true
        end

        it 'returns `false` when attributes missing' do
          expect(action).to receive(:attributes).and_return({})
          subject.attributes = nil
          expect(subject.valid?).to be false
        end

        it 'returns `false` when attribute is invalid' do
          expect(action).to receive(:attributes).and_return({})
          expect(subject.attributes['method']).to receive(:valid!).and_raise(
            Occi::Core::Errors::AttributeValidationError
          )
          expect(subject.valid?).to be false
        end
      end

      describe '#valid!' do
        it 'does not raise error when action and attributes valid' do
          expect(action).to receive(:attributes).and_return({})
          expect(subject.attributes['method']).to receive(:valid!)
          expect { subject.valid! }.not_to raise_error
        end

        it 'raises error when attributes missing' do
          expect(action).to receive(:attributes).and_return({})
          subject.attributes = nil
          expect { subject.valid! }.to raise_error(Occi::Core::Errors::InstanceValidationError)
        end

        it 'raises error when attribute is invalid' do
          expect(action).to receive(:attributes).and_return({})
          expect(subject.attributes['method']).to receive(:valid!).and_raise(
            Occi::Core::Errors::AttributeValidationError
          )
          expect { subject.valid! }.to raise_error(Occi::Core::Errors::AttributeValidationError)
        end
      end
    end
  end
end
