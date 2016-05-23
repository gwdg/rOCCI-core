module Occi
  module Core
    describe Category do
      subject { category }

      let(:category) do
        Category.new(
          term: 'generic',
          schema: 'http://schemas.org/schema#',
          title: 'Generic category',
          attribute_definitions: instance_double('Occi::Core::AttributeDefinitions')
        )
      end

      it 'has term accessor' do
        is_expected.to have_attr_accessor :term
      end

      it 'has schema accessor' do
        is_expected.to have_attr_accessor :schema
      end

      it 'has title accessor' do
        is_expected.to have_attr_accessor :title
      end

      it 'has attribute_definitions accessor' do
        is_expected.to have_attr_accessor :attribute_definitions
      end

      it 'has only a reader for identifier' do
        is_expected.to have_attr_reader_only :identifier
      end

      describe '.valid?' do
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

        it 'is valid with empty title' do
          category.title = nil
          expect(category.valid?).to be true
        end

        it 'is valid with attribute definitions' do
          expect(category.attribute_definitions).not_to be_nil
          expect(category.valid?).to be true
        end

        it 'is valid with empty attribute definitions' do
          expect(category.attribute_definitions).to be_empty
          expect(category.valid?).to be true
        end
      end

      describe '.validate' do
        it 'passes validation when valid' do
          expect(category.validate).to be true
        end

        it 'does not pass validation when invalid' do
          category.term = nil
          expect(category.validate).to be false
        end
      end

      describe '.validate!' do
        it 'raises an error when validated with bang and invalid' do
          category.term = nil
          expect { category.validate! }.to raise_error(Occi::Core::Errors::ValidationError)
        end

        it 'does not raise an error when validated with bang and valid' do
          expect { category.validate! }.not_to raise_error(Occi::Core::Errors::ValidationError)
        end
      end

      describe '.render' do
        it 'cannot be directly rendered'
      end

      describe '.empty?' do
        it 'can be checked for emptiness'
      end

      describe '.eql?' do
        it 'can be compared with another instance'
      end

      describe '.==' do
        it 'can be compared with another instance'
      end

      describe '.hash' do
        it 'has output'
        it 'has a consistent output'
        it 'changes output when identifier changes'
        it 'does not change output when title changes'
        it 'does not change output when attribute definitions change'
      end
    end
  end
end
