module Occi
  module Core
    describe AttributeDefinition do
      subject { attribute_definition }

      let(:attribute_definition) do
        AttributeDefinition.new(
          type: String,
          required: false,
          mutable: true,
          default: nil,
          description: 'Some description',
          pattern: /.*/
        )
      end

      ATTR_DEF_ATTRS = [:type, :required, :mutable, :default, :description, :pattern].freeze

      ATTR_DEF_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      describe '::new' do
        it 'fails without type'

        ATTR_DEF_ATTRS.each do |attr|
          it "assigns #{attr}"
        end
      end

      describe '#required?' do
        it 'matches required attribute'
      end

      describe '#required!' do
        it 'does not change `true` required attribute'
        it 'changes `false` required attribute'
        it 'changes `nil` required attribute'
      end

      describe '#optional?' do
        it 'matches negated required attribute'
      end

      describe '#optional!' do
        it 'does not change `false` required attribute'
        it 'changes `true` required attribute'
        it 'changes `nil` required attribute'
      end

      describe '#mutable?' do
        it 'matches mutable attribute'
      end

      describe '#mutable!' do
        it 'does not change `true` mutable attribute'
        it 'changes `false` mutable attribute'
        it 'changes `nil` mutable attribute'
      end

      describe '#immutable?' do
        it 'matches negated mutable attribute'
      end

      describe '#immutable!' do
        it 'does not change `false` mutable attribute'
        it 'changes `true` mutable attribute'
        it 'changes `nil` mutable attribute'
      end

      describe '#valid?' do
      end

      describe '#valid!' do
      end
    end
  end
end
