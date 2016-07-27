module Occi
  module Core
    describe AttributeDefinition do
      subject { attribute_definition }

      let(:example_type) { String }
      let(:example_required) { false }
      let(:example_mutable) { true }
      let(:example_default) { 'Some text' }
      let(:example_description) { 'Some description' }
      let(:example_pattern) { /.*/ }

      let(:attribute_definition) do
        AttributeDefinition.new(
          type: example_type,
          required: example_required,
          mutable: example_mutable,
          default: example_default,
          description: example_description,
          pattern: example_pattern
        )
      end

      ATTR_DEF_ATTRS = [:type, :required, :mutable, :default, :description, :pattern].freeze

      ATTR_DEF_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has logger' do
        expect(subject).to respond_to(:logger)
        expect(subject.class).to respond_to(:logger)
      end

      describe '::new' do
        ATTR_DEF_ATTRS.each do |attr|
          it "assigns #{attr}" do
            expect(subject.send(attr)).to match send("example_#{attr}")
          end
        end

        it 'fails with `nil` type' do
          expect { AttributeDefinition.new(type: nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
        end

        it 'fails with `nil` mutable' do
          expect { AttributeDefinition.new(mutable: nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
        end

        it 'fails with `nil` required' do
          expect { AttributeDefinition.new(required: nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
        end
      end

      describe '#required?' do
        it 'matches required attribute' do
          expect(subject.required?).to match example_required
        end
      end

      describe '#required!' do
        it 'does not change `true` required attribute' do
          subject.required = true
          subject.required!
          expect(subject.required).to be true
        end

        it 'changes `false` required attribute' do
          subject.required = false
          subject.required!
          expect(subject.required).to be true
        end

        it 'changes `nil` required attribute' do
          subject.required = nil
          subject.required!
          expect(subject.required).to be true
        end
      end

      describe '#optional?' do
        it 'matches negated required attribute' do
          expect(subject.optional?).to be !subject.required?
        end
      end

      describe '#optional!' do
        it 'does not change `false` required attribute' do
          subject.required = false
          subject.optional!
          expect(subject.required). to be false
        end

        it 'changes `true` required attribute' do
          subject.required = true
          subject.optional!
          expect(subject.required).to be false
        end

        it 'changes `nil` required attribute' do
          subject.required = nil
          subject.optional!
          expect(subject.required).to be false
        end
      end

      describe '#mutable?' do
        it 'matches mutable attribute' do
          expect(subject.mutable?).to match example_mutable
        end
      end

      describe '#mutable!' do
        it 'does not change `true` mutable attribute' do
          subject.mutable = true
          subject.mutable!
          expect(subject.mutable).to be true
        end

        it 'changes `false` mutable attribute' do
          subject.mutable = false
          subject.mutable!
          expect(subject.mutable).to be true
        end

        it 'changes `nil` mutable attribute' do
          subject.mutable = nil
          subject.mutable!
          expect(subject.mutable).to be true
        end
      end

      describe '#immutable?' do
        it 'matches negated mutable attribute' do
          expect(subject.immutable?).to be !subject.mutable?
        end
      end

      describe '#immutable!' do
        it 'does not change `false` mutable attribute' do
          subject.mutable = false
          subject.immutable!
          expect(subject.mutable).to be false
        end

        it 'changes `true` mutable attribute' do
          subject.mutable = true
          subject.immutable!
          expect(subject.mutable).to be false
        end

        it 'changes `nil` mutable attribute' do
          subject.mutable = nil
          subject.immutable!
          expect(subject.mutable).to be false
        end
      end

      describe '#default?' do
        it 'reports non-`nil` default value as `true`' do
          subject.default = example_default
          expect(subject.default?).to be true
        end

        it 'reports `nil` default value as `false`' do
          subject.default = nil
          expect(subject.default?).to be false
        end
      end

      describe '#pattern?' do
        it 'reports non-`nil` pattern value as `true`' do
          subject.pattern = example_pattern
          expect(subject.pattern?).to be true
        end

        it 'reports `nil` pattern value as `false`' do
          subject.pattern = nil
          expect(subject.pattern?).to be false
        end
      end

      context 'value validation' do
        let(:example_value1) { 'String' }
        let(:example_value2) { 25.02 }
        let(:example_value3) { '' }
        let(:example_value_nil) { nil }
        let(:example_strict_pattern) { /\S+/ }

        describe '#valid?' do
          it 'returns `true` to indicate success' do
            expect(subject.valid?(example_value1)).to be true
          end

          it 'returns `false` to indicate failure on type' do
            expect(subject.valid?(example_value2)).to be false
          end

          it 'returns `false` to indicate failure on pattern' do
            subject.pattern = example_strict_pattern
            expect(subject.valid?(example_value3)).to be false
          end

          it 'returns `false` for empty required attribute' do
            subject.required = true
            expect(subject.valid?(example_value_nil)).to be false
          end

          it 'returns `true` to indicate success without pattern' do
            subject.pattern = nil
            expect(subject.valid?(example_value3)).to be true
          end
        end

        describe '#valid!' do
          it 'does not raise error to indicate success' do
            expect { subject.valid!(example_value1) }.not_to raise_error
          end

          it 'raises error with message to indicate failure on type' do
            expect { subject.valid!(example_value2) }.to raise_error(Occi::Core::Errors::AttributeValidationError)
          end

          it 'raises error with message to indicate failure on pattern' do
            subject.pattern = example_strict_pattern
            expect { subject.valid!(example_value3) }.to raise_error(Occi::Core::Errors::AttributeValidationError)
          end

          it 'raises error for empty required attribute' do
            subject.required = true
            expect { subject.valid!(example_value_nil) }.to raise_error(Occi::Core::Errors::AttributeValidationError)
          end

          it 'does not raise error to indicate success without pattern' do
            subject.pattern = nil
            expect { subject.valid!(example_value3) }.not_to raise_error
          end
        end
      end
    end
  end
end
