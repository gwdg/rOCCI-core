module Occi
  module Core
    describe Category do
      subject { category }

      let(:example_term) { 'generic' }
      let(:example_schema) { 'http://schemas.org/schema#' }
      let(:example_title) { 'Generic category' }

      let(:example_attribute) { 'org.example.attribute' }
      let(:example_value) { 'text' }

      let(:category) do
        Category.new(
          term: example_term,
          schema: example_schema,
          title: example_title,
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
        it 'fails without term' do
          expect { Category.new(term: nil, schema: example_schema) }.to raise_error(Occi::Core::Errors::InvalidEntry)
        end

        it 'fails with empty term' do
          expect { Category.new(term: '', schema: example_schema) }.to raise_error(Occi::Core::Errors::InvalidEntry)
        end

        it 'fails without schema' do
          expect { Category.new(term: example_term, schema: nil) }.to raise_error(Occi::Core::Errors::InvalidEntry)
        end

        it 'fails with empty schema' do
          expect { Category.new(term: example_term, schema: '') }.to raise_error(Occi::Core::Errors::InvalidEntry)
        end

        it 'fails with invalid term'
        it 'fails with invalid schema'

        CAT_ATTRS.each do |attr|
          it "assigns #{attr}"
        end
      end

      describe '#[]' do
        it 'delegates to attribute definitions' do
          expect(category.attribute_definitions).to receive(:[]).with(example_attribute)
          category[example_attribute]
        end
      end

      describe '#[]=' do
        it 'delegates to attribute definitions' do
          expect(category.attribute_definitions).to receive(:[]=).with(example_attribute, example_value)
          category[example_attribute] = example_value
        end
      end

      describe '#render' do
        it 'raises a rendering error' do
          expect { category.render :text }.to raise_error(Occi::Core::Errors::RenderingError)
        end
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

      describe '#to_<format>' do
        it 'redirects to #render when renderer available'
        it 'prefers renderer to local methods'
        it 'executes locally if method available'
        it 'raises error when completely missing'
      end

      describe '#respond_to?' do
        it 'returns `true` for missing to_<format> methods' do
          expect(category.methods).not_to include(:to_text)
          expect(category.respond_to?(:to_text)).to be true
        end

        it 'returns `true` for existing to_<format> methods' do
          expect(category.methods).to include(:to_s)
          expect(category.respond_to?(:to_s)).to be true
        end

        it 'returns `false` on missing methods' do
          expect(category.methods).not_to include(:this_is_not_there)
          expect(category.respond_to?(:this_is_not_there)).to be false
        end
      end
    end
  end
end
