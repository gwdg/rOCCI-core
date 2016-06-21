module Occi
  module Core
    describe Attribute do
      subject { attribute }

      let(:attribute) do
        Attribute.new('text', instance_double('Occi::Core::AttributeDefinition'))
      end

      let(:noval_attribute) do
        Attribute.new(nil, instance_double('Occi::Core::AttributeDefinition'))
      end

      let(:nodef_attribute) do
        Attribute.new('text', nil)
      end

      let(:empty_attribute) do
        Attribute.new(nil, nil)
      end

      ATTR_ATTRS = [:value, :attribute_definition].freeze

      ATTR_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      describe '#valid?' do
        it 'returns `true` when valid' do
          expect(subject.attribute_definition).to receive(:valid!).with(subject.value)
          expect { subject.valid? }.not_to raise_error
        end

        it 'returns `false` when definition is missing' do
          expect(nodef_attribute.valid?).to be false
          expect { nodef_attribute.valid? }.not_to raise_error
        end

        it 'returns `false` when value does not match definition' do
          expect(subject.attribute_definition).to receive(:valid!).with(
            subject.value
          ).and_raise(Occi::Core::Errors::AttributeValidationError)
          expect(subject.valid?).to be false
        end
      end

      describe '#valid!' do
        it 'raises error when value does not match definition' do
          expect(subject.attribute_definition).to receive(:valid!).with(
            subject.value
          ).and_raise(Occi::Core::Errors::AttributeValidationError)
          expect { subject.valid! }.to raise_error(Occi::Core::Errors::AttributeValidationError)
        end

        it 'raises error when definition is missing' do
          expect { nodef_attribute.valid! }.to raise_error(Occi::Core::Errors::AttributeValidationError)
        end

        it 'does not raise error when valid' do
          expect(subject.attribute_definition).to receive(:valid!).with(subject.value)
          expect { subject.valid! }.not_to raise_error
        end
      end

      describe '#definition?' do
        it 'returns `true` when definition is present' do
          expect(subject.definition?).to be true
        end

        it 'returns `false` when definition is missing' do
          expect(nodef_attribute.definition?).to be false
        end
      end

      describe '#value?' do
        it 'returns `true` when value is present' do
          expect(subject.value?).to be true
        end

        it 'returns `false` when value is missing' do
          expect(noval_attribute.value?).to be false
        end
      end

      describe '#full?' do
        it 'returns `true` when definition and value are present' do
          expect(subject.full?).to be true
        end

        it 'returns `false` when definition is missing' do
          expect(nodef_attribute.full?).to be false
        end

        it 'returns `false` when value is missing' do
          expect(noval_attribute.full?).to be false
        end

        it 'returns `false` when both value and definition are missing' do
          expect(empty_attribute.full?).to be false
        end
      end

      describe '#empty?' do
        it 'returns `false` when definition and value are present' do
          expect(subject.empty?).to be false
        end

        it 'returns `false` when just definition is missing' do
          expect(nodef_attribute.empty?).to be false
        end

        it 'returns `false` when just value is missing' do
          expect(noval_attribute.empty?).to be false
        end

        it 'returns `true` when both value and definition are missing' do
          expect(empty_attribute.empty?).to be true
        end
      end

      describe '#default' do
        it 'sets default value when `nil`' do
          expect(noval_attribute.value).to eq nil
          expect(noval_attribute.attribute_definition).to receive(:default).and_return('deftext')
          expect { noval_attribute.default }.not_to raise_error
          expect(noval_attribute.value).to eq 'deftext'
        end

        it 'does not set default value when not `nil`' do
          expect(subject.value).to eq 'text'
          expect(subject.attribute_definition).not_to receive(:default)
          expect { subject.default }.not_to raise_error
          expect(subject.value).to eq 'text'
        end

        it 'raises error when definition is missing and value is `nil`' do
          expect { empty_attribute.default }.to raise_error(Occi::Core::Errors::AttributeDefinitionError)
        end

        it 'does not raise error when definition is missing and value is not `nil`' do
          expect { nodef_attribute.default }.not_to raise_error
        end

        it 'returns new value on change' do
          expect(noval_attribute.attribute_definition).to receive(:default).and_return('deftext')
          expect(noval_attribute.default).to eq 'deftext'
        end

        it 'returns `nil` when nothing changed' do
          expect(subject.attribute_definition).not_to receive(:default)
          expect(subject.default).to be nil
        end
      end

      describe '#default!' do
        it 'sets default value when `nil`' do
          expect(noval_attribute.value).to eq nil
          expect(noval_attribute.attribute_definition).to receive(:default).and_return('deftext')
          expect { noval_attribute.default! }.not_to raise_error
          expect(noval_attribute.value).to eq 'deftext'
        end

        it 'sets default value when value not `nil`' do
          expect(subject.value).to eq 'text'
          expect(subject.attribute_definition).to receive(:default).and_return('deftext')
          expect { subject.default! }.not_to raise_error
          expect(subject.value).to eq 'deftext'
        end

        it 'raises error when definition is missing' do
          expect { nodef_attribute.default! }.to raise_error(Occi::Core::Errors::AttributeDefinitionError)
        end

        it 'returns new value' do
          expect(noval_attribute.attribute_definition).to receive(:default).and_return('deftext')
          expect(noval_attribute.default!).to eq 'deftext'
        end
      end

      describe '#reset!' do
        it 'changes the attribute value to `nil`' do
          expect(subject.value).not_to be nil
          expect { subject.reset! }.not_to raise_error
          expect(subject.value).to be nil
        end
      end
    end
  end
end
