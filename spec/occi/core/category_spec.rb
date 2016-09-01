module Occi
  module Core
    describe Category do
      subject(:cat) { category }

      let(:example_term) { 'generic' }
      let(:example_schema) { 'http://schemas.org/schema#' }
      let(:example_title) { 'Generic category' }
      let(:example_attributes) { Hash.new }

      let(:category) do
        Category.new(
          term: example_term,
          schema: example_schema,
          title: example_title,
          attributes: example_attributes
        )
      end

      let(:category_other) do
        Category.new(
          term: "#{example_term}2",
          schema: example_schema,
          title: example_title,
          attributes: example_attributes
        )
      end

      let(:category_same) do
        Category.new(
          term: example_term,
          schema: example_schema,
          title: example_title,
          attributes: example_attributes
        )
      end

      CAT_ATTRS = [:term, :schema, :title, :attributes].freeze

      CAT_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has only a reader for identifier' do
        is_expected.to have_attr_reader_only :identifier
      end

      it 'has logger' do
        expect(cat).to respond_to(:logger)
        expect(cat.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(cat).to be_kind_of(Helpers::Renderable)
        expect(cat).to respond_to(:render)
      end

      it 'has attributes value accessor' do
        expect(cat).to be_kind_of(Helpers::AttributesAccessor)
        expect(cat).to respond_to(:[])
        expect(cat).to respond_to(:[]=)
      end

      describe '::new' do
        it 'fails without term' do
          expect { Category.new(term: nil, schema: example_schema) }.to raise_error(
            Occi::Core::Errors::MandatoryArgumentError
          )
        end

        it 'fails with empty term' do
          expect { Category.new(term: '', schema: example_schema) }.to raise_error(
            Occi::Core::Errors::MandatoryArgumentError
          )
        end

        it 'fails without schema' do
          expect { Category.new(term: example_term, schema: nil) }.to raise_error(
            Occi::Core::Errors::MandatoryArgumentError
          )
        end

        it 'fails with empty schema' do
          expect { Category.new(term: example_term, schema: '') }.to raise_error(
            Occi::Core::Errors::MandatoryArgumentError
          )
        end

        it 'fails with invalid term' do
          expect { Category.new(term: 'as tr%$^!', schema: example_schema) }.to raise_error(
            Occi::Core::Errors::MandatoryArgumentError
          )
        end

        it 'fails with invalid schema' do
          expect { Category.new(term: example_term, schema: 'sf 5as4%$61&') }.to raise_error(
            Occi::Core::Errors::MandatoryArgumentError
          )
        end

        CAT_ATTRS.each do |attr|
          it "assigns #{attr}" do
            expect(cat.send(attr)).to match send("example_#{attr}")
          end
        end
      end

      %w(identifier to_s).each do |mtd|
        describe "##{mtd}" do
          it 'returns category identifier as URI string' do
            expect(cat.send(mtd)).to be_kind_of String
            expect { URI.parse(cat.send(mtd)) }.not_to raise_error
          end

          it 'returns a join of schema and term' do
            expect(cat.send(mtd)).to eq "#{cat.schema}#{cat.term}"
          end
        end
      end

      describe '#==' do
        context 'with same category' do
          it 'returns `true`' do
            expect(cat == category_same).to be true
          end
        end

        context 'without category' do
          it 'returns `false`' do
            expect(cat == nil).to be false
          end
        end

        context 'with different object' do
          it 'returns `false`' do
            expect(cat == Object.new).to be false
          end
        end

        context 'with different category' do
          it 'returns `false`' do
            expect(cat == category_other).to be false
          end
        end
      end

      describe '#eql?' do
        context 'with same category' do
          it 'returns `true`' do
            expect(cat.eql?(category_same)).to be true
          end
        end

        context 'without category' do
          it 'returns `false`' do
            expect(cat.eql?(nil)).to be false
          end
        end

        context 'with different object' do
          it 'returns `false`' do
            expect(cat.eql?(Object.new)).to be false
          end
        end

        context 'with different category' do
          it 'returns `false`' do
            expect(cat.eql?(category_other)).to be false
          end
        end
      end

      describe '#hash' do
        it 'returns value' do
          expect(cat.hash).not_to be_nil
        end

        context 'between different categories' do
          it 'differs' do
            expect(cat.hash).not_to eq category_other.hash
          end
        end

        context 'between same categories' do
          it 'equals' do
            expect(cat.hash).to eq category_same.hash
          end
        end
      end
    end
  end
end
