module Occi
  module Core
    describe Category do
      subject { category }

      let(:example_term) { 'generic' }
      let(:example_schema) { 'http://schemas.org/schema#' }
      let(:example_title) { 'Generic category' }
      let(:example_attributes) { instance_double('Hash') }

      let(:example_attribute) { 'org.example.attribute' }
      let(:example_value) { 'text' }

      let(:category) do
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
            expect(subject.send(attr)).to match send("example_#{attr}")
          end
        end
      end

      describe '#[]' do
        it 'delegates to attributes' do
          expect(subject.attributes).to receive(:[]).with(example_attribute)
          subject[example_attribute]
        end
      end

      describe '#[]=' do
        it 'delegates to attributes' do
          expect(subject.attributes).to receive(:[]=).with(example_attribute, example_value)
          subject[example_attribute] = example_value
        end
      end

      context 'during URI validation' do
        let(:example_invalid_term) { 'term safa %$%$%426&' }
        let(:example_invalid_schema) { 'http:// asd df %^$@%@$% as/dsd#' }
        let(:example_invalid_idf) { "#{example_invalid_schema}#{example_invalid_term}" }

        describe '::valid_term?' do
          it 'recognizes valid term' do
            expect(Category.valid_term?(subject.term)).to be true
          end

          it 'fails on non-URI compliant term' do
            expect(Category.valid_term?(example_invalid_term)).to be false
          end
        end

        describe '::valid_schema?' do
          it 'recognizes valid schema' do
            expect(Category.valid_schema?(subject.schema)).to be true
          end

          it 'fails on non-URI compliant schema' do
            expect(Category.valid_schema?(example_invalid_schema)).to be false
          end
        end

        describe '::valid_identifier?' do
          it 'recognizes valid identifier' do
            expect(Category.valid_identifier?(subject.identifier)).to be true
          end

          it 'fails on non-URI compliant identifier' do
            expect(Category.valid_identifier?(example_invalid_idf)).to be false
          end
        end

        describe '::valid_term!' do
          it 'recognizes valid term' do
            expect { Category.valid_term!(subject.term) }.not_to raise_error
          end

          it 'fails on non-URI compliant term' do
            expect { Category.valid_term!(example_invalid_term) }.to raise_error(
              Occi::Core::Errors::CategoryValidationError
            )
          end
        end

        describe '::valid_schema!' do
          it 'recognizes valid schema' do
            expect { Category.valid_schema!(subject.schema) }.not_to raise_error
          end

          it 'fails on non-URI compliant schema' do
            expect { Category.valid_schema!(example_invalid_schema) }.to raise_error(
              URI::InvalidURIError
            )
          end
        end

        describe '::valid_identifier!' do
          it 'recognizes valid identifier' do
            expect { Category.valid_identifier!(subject.identifier) }.not_to raise_error
          end

          it 'fails on non-URI compliant identifier' do
            expect { Category.valid_identifier!(example_invalid_idf) }.to raise_error(
              URI::InvalidURIError
            )
          end
        end
      end
    end
  end
end
