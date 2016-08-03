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
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has logger' do
        expect(subject).to respond_to(:logger)
        expect(subject.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(subject).to be_kind_of(Helpers::Renderable)
        expect(subject).to respond_to(:render)
      end

      it 'has attributes value accessor' do
        expect(subject).to be_kind_of(Helpers::InstanceAttributesAccessor)
        expect(subject).to respond_to(:[])
        expect(subject).to respond_to(:[]=)
        expect(subject).to respond_to(:attribute?)
      end

      describe '#valid?' do
        it 'returns `true` when action and attributes valid' do
          expect(subject.attributes['method']).to receive(:valid!)
          expect(subject.valid?).to be true
        end

        it 'returns `false` when action missing' do
          subject.action = nil
          expect(subject.valid?).to be false
        end

        it 'returns `false` when attributes missing' do
          subject.attributes = nil
          expect(subject.valid?).to be false
        end

        it 'returns `false` when attribute is invalid' do
          expect(subject.attributes['method']).to receive(:valid!).and_raise(
            Occi::Core::Errors::AttributeValidationError
          )
          expect(subject.valid?).to be false
        end

        it 'returns `false` when both action and attributes missing' do
          subject.attributes = nil
          subject.action = nil
          expect(subject.valid?).to be false
        end
      end

      describe '#valid!' do
        it 'does not raise error when action and attributes valid' do
          expect(subject.attributes['method']).to receive(:valid!)
          expect { subject.valid! }.not_to raise_error
        end

        it 'raises error when action missing' do
          subject.action = nil
          expect { subject.valid! }.to raise_error(Occi::Core::Errors::InstanceValidationError)
        end

        it 'raises error when attributes missing' do
          subject.attributes = nil
          expect { subject.valid! }.to raise_error(Occi::Core::Errors::InstanceValidationError)
        end

        it 'raises error when attribute is invalid' do
          expect(subject.attributes['method']).to receive(:valid!).and_raise(
            Occi::Core::Errors::AttributeValidationError
          )
          expect { subject.valid! }.to raise_error(Occi::Core::Errors::AttributeValidationError)
        end

        it 'raises error when both action and attributes missing' do
          subject.action = nil
          subject.attributes = nil
          expect { subject.valid! }.to raise_error(Occi::Core::Errors::InstanceValidationError)
        end
      end
    end
  end
end
