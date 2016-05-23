module Occi
  module Core
    describe Category do
      let(:category) do
        Category.new(
          term: 'generic',
          schema: 'http://schemas.org/schema#',
          title: 'Generic category',
          attribute_definitions: double('attribute_definitions')
        )
      end

      it 'has term' do
        expect(category.term).to eq 'generic'
      end

      it 'has schema' do
        expect(category.schema).to eq 'http://schemas.org/schema#'
      end

      it 'has title' do
        expect(category.title).to eq 'Generic category'
      end

      it 'has identifier' do
        expect(category.identifier).to eq 'http://schemas.org/schema#generic'
      end

      it 'has attribute definitions' do
        expect(category.attribute_definitions).not_to be_nil
      end

      it 'allows the change of term' do
        expect { category.term = 'nope' }.not_to raise_error
        expect(category.term).to eq 'nope'
      end

      it 'allows the change of schema' do
        expect { category.schema = 'http://schemas.org/nope#' }.not_to raise_error
        expect(category.schema).to eq 'http://schemas.org/nope#'
      end

      it 'allows the change of title' do
        expect { category.title = 'Nope category' }.not_to raise_error
        expect(category.title).to eq 'Nope category'
      end

      it 'does not allow the change of identifier' do
        expect { category.identifier = 'http://schemas.org/nope#nope' }.to raise_error(NoMethodError)
        expect(category.identifier).to eq 'http://schemas.org/schema#generic'
      end

      it 'allows the change of attribute definitions' do
        old_attribute_definitions = category.attribute_definitions
        expect { category.attribute_definitions = double('attribute_definitions') }.not_to raise_error
        expect(category.attribute_definitions).not_to equal old_attribute_definitions
      end

      it 'is invalid without term' do
        category.term = nil
        expect(category.valid?).to be false
      end

      it 'is invalid with empty term' do
        category.term = ''
        expect(category.valid?).to be false
      end

      it 'is invalid with invalid term' do
        category.term = '*%^3*5636 43 32456//'
        expect(category.valid?).to be false
      end

      it 'is invalid without schema' do
        category.schema = nil
        expect(category.valid?).to be false
      end

      it 'is invalid with empty schema' do
        category.schema = ''
        expect(category.valid?).to be false
      end

      it 'is invalid with invalid schema' do
        category.schema = '%$4565+ 25 2+65 //=='
        expect(category.valid?).to be false
      end

      it 'is invalid without attribute definitions' do
        category.attribute_definitions = nil
        expect(category.valid?).to be false
      end

      it 'is valid with valid term, schema, title, and attribute definitions' do
        expect(category.valid?).to be true
      end

      it 'is valid without title' do
        category.title = nil
        expect(category.valid?).to be true
      end

      it 'is valid with attribute definitions' do
        expect(category.attribute_definitions).not_to be_nil
        expect(category.valid?).to be true
      end

      it 'passes validation when valid' do
        expect(category.valid?).to be true
        expect(category.validate).to be true
      end

      it 'does not pass validation when invalid' do
        category.term = nil
        expect(category.valid?).to be false
        expect(category.validate).to be false
      end

      it 'raises an error when validated with bang and invalid' do
        category.term = nil
        expect(category.valid?).to be false
        expect { category.validate! }.to raise_error
      end

      it 'does not raise an error when validated with bang and valid' do
        expect(category.valid?).to be true
        expect { category.validate! }.not_to raise_error
      end

      it 'cannot be directly rendered'
      it 'can be checked for emptiness'
      it 'can be compared with another instance'
    end
  end
end
