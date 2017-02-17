module Occi
  module Core
    describe AttributeDefinition do
      subject(:attr_def) { attribute_definition }

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
        expect(attr_def).to respond_to(:logger)
        expect(attr_def.class).to respond_to(:logger)
      end

      describe '::new' do
        ATTR_DEF_ATTRS.each do |attr|
          it "assigns #{attr}" do
            expect(attr_def.send(attr)).to match send("example_#{attr}")
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
          expect(attr_def.required?).to match example_required
        end
      end

      describe '#required!' do
        it 'does not change `true` required attribute' do
          attr_def.required = true
          attr_def.required!
          expect(attr_def.required).to be true
        end

        it 'changes `false` required attribute' do
          attr_def.required = false
          attr_def.required!
          expect(attr_def.required).to be true
        end

        it 'changes `nil` required attribute' do
          attr_def.required = nil
          attr_def.required!
          expect(attr_def.required).to be true
        end
      end

      describe '#optional?' do
        it 'matches negated required attribute' do
          expect(attr_def.optional?).to be !attr_def.required?
        end
      end

      describe '#optional!' do
        it 'does not change `false` required attribute' do
          attr_def.required = false
          attr_def.optional!
          expect(attr_def.required). to be false
        end

        it 'changes `true` required attribute' do
          attr_def.required = true
          attr_def.optional!
          expect(attr_def.required).to be false
        end

        it 'changes `nil` required attribute' do
          attr_def.required = nil
          attr_def.optional!
          expect(attr_def.required).to be false
        end
      end

      describe '#mutable?' do
        it 'matches mutable attribute' do
          expect(attr_def.mutable?).to match example_mutable
        end
      end

      describe '#mutable!' do
        it 'does not change `true` mutable attribute' do
          attr_def.mutable = true
          attr_def.mutable!
          expect(attr_def.mutable).to be true
        end

        it 'changes `false` mutable attribute' do
          attr_def.mutable = false
          attr_def.mutable!
          expect(attr_def.mutable).to be true
        end

        it 'changes `nil` mutable attribute' do
          attr_def.mutable = nil
          attr_def.mutable!
          expect(attr_def.mutable).to be true
        end
      end

      describe '#immutable?' do
        it 'matches negated mutable attribute' do
          expect(attr_def.immutable?).to be !attr_def.mutable?
        end
      end

      describe '#immutable!' do
        it 'does not change `false` mutable attribute' do
          attr_def.mutable = false
          attr_def.immutable!
          expect(attr_def.mutable).to be false
        end

        it 'changes `true` mutable attribute' do
          attr_def.mutable = true
          attr_def.immutable!
          expect(attr_def.mutable).to be false
        end

        it 'changes `nil` mutable attribute' do
          attr_def.mutable = nil
          attr_def.immutable!
          expect(attr_def.mutable).to be false
        end
      end

      describe '#default?' do
        it 'reports non-`nil` default value as `true`' do
          attr_def.default = example_default
          expect(attr_def.default?).to be true
        end

        it 'reports `nil` default value as `false`' do
          attr_def.default = nil
          expect(attr_def.default?).to be false
        end
      end

      describe '#pattern?' do
        it 'reports non-`nil` pattern value as `true`' do
          attr_def.pattern = example_pattern
          expect(attr_def.pattern?).to be true
        end

        it 'reports `nil` pattern value as `false`' do
          attr_def.pattern = nil
          expect(attr_def.pattern?).to be false
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
            expect(attr_def.valid?(example_value1)).to be true
          end

          it 'returns `false` to indicate failure on type' do
            expect(attr_def.valid?(example_value2)).to be false
          end

          it 'returns `false` to indicate failure on pattern' do
            attr_def.pattern = example_strict_pattern
            expect(attr_def.valid?(example_value3)).to be false
          end

          it 'returns `false` for empty required attribute' do
            attr_def.required = true
            expect(attr_def.valid?(example_value_nil)).to be false
          end

          it 'returns `true` for empty optional attribute' do
            attr_def.required = false
            expect(attr_def.valid?(example_value_nil)).to be true
          end

          it 'returns `true` to indicate success without pattern' do
            attr_def.pattern = nil
            expect(attr_def.valid?(example_value3)).to be true
          end
        end

        describe '#valid!' do
          let(:example_type_ent) { Occi::Core::Entity }
          let(:example_kind) { Occi::Core::Kind.new schema: 'http://my/test#', term: 'kind' }
          let(:example_value_res) { Occi::Core::Resource.new kind: example_kind, id: SecureRandom.uuid }

          it 'does not raise error to indicate success' do
            expect { attr_def.valid!(example_value1) }.not_to raise_error
          end

          it 'raises error with message to indicate failure on type' do
            expect { attr_def.valid!(example_value2) }.to raise_error(Occi::Core::Errors::AttributeValidationError)
          end

          it 'raises error with message to indicate failure on pattern' do
            attr_def.pattern = example_strict_pattern
            expect { attr_def.valid!(example_value3) }.to raise_error(Occi::Core::Errors::AttributeValidationError)
          end

          it 'raises error for empty required attribute' do
            attr_def.required = true
            expect { attr_def.valid!(example_value_nil) }.to raise_error(Occi::Core::Errors::AttributeValidationError)
          end

          it 'does not raise error for empty optional attribute' do
            attr_def.required = false
            expect { attr_def.valid!(example_value_nil) }.not_to raise_error
          end

          it 'does not raise error to indicate success without pattern' do
            attr_def.pattern = nil
            expect { attr_def.valid!(example_value3) }.not_to raise_error
          end

          it 'does not raise error for sub-types of defined type' do
            attr_def.type = example_type_ent
            expect { attr_def.valid!(example_value_res) }.not_to raise_error
          end
        end
      end
    end
  end
end
