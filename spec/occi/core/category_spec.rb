module Occi
  module Core
    describe Category do

      let(:category) { Category.new }
      let(:category_scheme) { Category.new 'http://example.org/test#', 'category' }
      let(:category_term) { Category.new 'http://schemas.ogf.org/occi/core#', 'testcat' }
      let(:category_scheme_term) { Category.new *'http://schemas.ogf.org/occi/test#category1'.split('#') }

      context '#new' do

        it 'with defaults' do
          expect {Category.new}.not_to raise_error
        end

      end

      context 'instance attributes' do

        it 'default scheme is OGF OCCI Core' do
          expect(category.scheme).to eq 'http://schemas.ogf.org/occi/core#'
        end

        it 'default term is "category"' do
          expect(category.term).to eq 'category'
        end

        it 'default title is nil' do
          expect(category.title).to be_nil
        end

        it 'default attributes are Occi::Core::Attributes' do
          expect(category.attributes).to be_kind_of Occi::Core::Attributes
        end

        it 'default attributes are empty' do
          expect(category.attributes).to be_empty
        end

        it 'scheme always ends with a #' do
          expect(category_scheme_term.scheme).to eq 'http://schemas.ogf.org/occi/test#'
        end

        it 'term is always after the #' do
          expect(category_scheme_term.term).to eq 'category1'
        end

      end

      context '#type_identifier' do

        it 'returns the type identifier of the category' do
          expect(category.type_identifier).to eq 'http://schemas.ogf.org/occi/core#category'
        end

      end

      context '#==' do

        it 'matches the same instance' do
          expect(category).to eq category
        end

        it 'matches a clone' do
          expect(category).to eq category.clone
        end

        it 'matches with a different title' do
          changed_clone = category.clone
          changed_clone.title = 'newtitle'

          expect(category).to eq changed_clone
        end

        it 'matches with different attributes' do
          changed_clone = category.clone
          changed_clone.attributes = Occi::Core::Attributes.new({ "id" => '123123' })

          expect(category).to eq changed_clone
        end

        it 'does not match a nil' do
          expect(category).not_to eq nil
        end

        it 'does not match with a different scheme' do
          expect(category).not_to eq category_scheme
        end

        it 'does not match with a different term' do
          expect(category).not_to eq category_term
        end

        it 'does not match with a different scheme and term' do
          expect(category).not_to eq category_scheme_term
        end

      end

      context '#eql?' do

        it 'matches the same instance' do
          expect(category).to eql category
        end

        it 'matches a clone' do
          expect(category).to eql category.clone
        end

        it 'matches with a different title' do
          changed_clone = category.clone
          changed_clone.title = 'newtitle'

          expect(category).to eql changed_clone
        end

        it 'matches with different attributes' do
          changed_clone = category.clone
          changed_clone.attributes = Occi::Core::Attributes.new({ "id" => '123123' })

          expect(category).to eql changed_clone
        end

        it 'does not match a nil' do
          expect(category).not_to eql nil
        end

        it 'does not match with a different scheme' do
          expect(category).not_to eql category_scheme
        end

        it 'does not match with a different term' do
          expect(category).not_to eql category_term
        end

        it 'does not match with a different scheme and term' do
          expect(category).not_to eql category_scheme_term
        end

      end

      context '#equal?' do

        it 'matches the same instance' do
          expect(category).to equal category
        end

        it 'does not match clones' do
          expect(category).not_to equal category.clone
        end

      end

      # rendering

    end
  end
end
