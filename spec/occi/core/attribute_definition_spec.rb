module Occi
  module Core
    describe AttributeDefinition do
      subject { attribute_definition }

      let(:attribute_definition) do
        AttributeDefinition.new(
          name: 'test.attribute',
          type: String,
          required: false,
          mutable: true,
          default: nil,
          description: 'Some description',
          pattern: /.*/
        )
      end

      ATTR_DEF_ATTRS = [:name, :type, :required, :mutable, :default, :description, :pattern].freeze

      ATTR_DEF_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      describe '.new' do
        it 'fails without name'
        it 'fails without type'

        ATTR_DEF_ATTRS.each do |attr|
          it "assigns #{attr}"
        end
      end

      describe '.required?' do
        it 'matches required attribute'
      end

      describe '.mutable?' do
        it 'matches mutable attribute'
      end

      describe '.mutable!' do
        it 'does not change `true` mutable attribute'
        it 'changes `false` mutable attribute'
        it 'changes `nil` mutable attribute'
      end

      describe '.immutable?' do
        it 'matches negated mutable attribute'
      end

      describe '.immutable!' do
        it 'does not change `false` mutable attribute'
        it 'changes `true` mutable attribute'
        it 'changes `nil` mutable attribute'
      end

      describe '.valid?' do
      end

      describe '.validate!' do
      end

      describe '.hash' do
        it 'has output'
        it 'has a consistent output'
        it 'changes output when name changes'

        (ATTR_DEF_ATTRS - [:name]).each do |attr|
          it "does not change output when #{attr} changes"
        end
      end
    end
  end
end
