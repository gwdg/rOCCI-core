module Occi
  module Core
    describe Category do
      subject { category }

      let(:category) do
        Category.new(
          term: 'generic',
          schema: 'http://schemas.org/schema#',
          title: 'Generic category',
          attribute_definitions: instance_double('Hash')
        )
      end

      CAT_ATTRS = [:term, :schema, :title, :attribute_definitions].freeze

      CAT_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has only a reader for identifier' do
        is_expected.to have_attr_reader_only :identifier
      end

      describe '::new' do
        it 'fails without term'
        it 'fails without schema'

        CAT_ATTRS.each do |attr|
          it "assigns #{attr}"
        end
      end

      describe '#[]' do
        it 'delegates to attribute definitions'
      end

      describe '#[]=' do
        it 'delegates to attribute definitions'
      end

      describe '#render' do
        it 'raises a rendering error'
      end

      describe '#empty?' do
        it 'returns `true` for blank term'
        it 'returns `true` for blank schema'
        it 'returns `false` for non-empty term and schema'
      end

      describe '#eql?' do
        it 'returns `false` for object without identifier'
        it 'returns `false` for object without matching identifier value'
        it 'returns `true` for object with matching identifier value'
      end

      describe '#==' do
        it 'returns `false` for object without identifier'
        it 'returns `false` for object without matching identifier value'
        it 'returns `true` for object with matching identifier value'
      end

      describe '#hash' do
        it 'has output'
        it 'has a consistent output'
        it 'changes output when identifier changes'
        it 'does not change output when title changes'
        it 'does not change output when attribute definitions change'
      end
    end
  end
end
