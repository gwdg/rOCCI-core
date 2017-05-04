module Occi
  module Core
    module Helpers
      describe IdentifierValidator do
        subject(:validatable) { Class.new.extend(IdentifierValidator) }

        let(:example_term) { 'generic' }
        let(:example_schema) { 'http://schemas.org/schema#' }
        let(:example_idf) { "#{example_schema}#{example_term}" }

        let(:example_invalid_term) { 'term safa %$%$%426&' }
        let(:example_invalid_schema) { 'http:// asd df %^$@%@$% as/dsd#' }
        let(:example_invalid_idf) { "#{example_invalid_schema}#{example_invalid_term}" }

        describe '::valid_term?' do
          it 'recognizes valid term' do
            expect(validatable.valid_term?(example_term)).to be true
          end

          it 'fails on non-URI compliant term' do
            expect(validatable.valid_term?(example_invalid_term)).to be false
          end
        end

        describe '::valid_schema?' do
          it 'recognizes valid schema' do
            expect(validatable.valid_schema?(example_schema)).to be true
          end

          it 'fails on non-URI compliant schema' do
            expect(validatable.valid_schema?(example_invalid_schema)).to be false
          end
        end

        describe '::valid_identifier?' do
          it 'recognizes valid identifier' do
            expect(validatable.valid_identifier?(example_idf)).to be true
          end

          it 'fails on non-URI compliant identifier' do
            expect(validatable.valid_identifier?(example_invalid_idf)).to be false
          end
        end

        describe '::valid_term!' do
          it 'recognizes valid term' do
            expect { validatable.valid_term!(example_term) }.not_to raise_error
          end

          it 'fails on non-URI compliant term' do
            expect { validatable.valid_term!(example_invalid_term) }.to raise_error(
              Occi::Core::Errors::CategoryValidationError
            )
          end
        end

        describe '::valid_schema!' do
          it 'recognizes valid schema' do
            expect { validatable.valid_schema!(example_schema) }.not_to raise_error
          end

          it 'fails on non-URI compliant schema' do
            expect { validatable.valid_schema!(example_invalid_schema) }.to raise_error(
              URI::InvalidURIError
            )
          end
        end

        describe '::valid_identifier!' do
          it 'recognizes valid identifier' do
            expect { validatable.valid_identifier!(example_idf) }.not_to raise_error
          end

          it 'fails on non-URI compliant identifier' do
            expect { validatable.valid_identifier!(example_invalid_idf) }.to raise_error(
              URI::InvalidURIError
            )
          end
        end
      end
    end
  end
end
