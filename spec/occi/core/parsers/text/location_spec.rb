module Occi
  module Core
    module Parsers
      module Text
        describe Location do
          subject(:lc) { Location }

          it 'has logger' do
            expect(lc).to respond_to(:logger)
          end

          describe '::plain' do
            context 'without input' do
              it 'fails for `nil`' do
                expect { lc.plain(nil) }.to raise_error(NoMethodError)
              end

              it 'returns empty array for empty enumerable' do
                expect(lc.plain([])).to be_empty
              end
            end

            context 'with valid lines' do
              let(:valid_prefix) { 'X-OCCI-Location: ' }
              let(:one_uri) { ["#{valid_prefix}http://localhost/test/something/1"] }
              let(:two_uris) do
                ['http://localhost/te/2', 'http://localhost/st/3'].map { |i| "#{valid_prefix}#{i}" }
              end
              let(:with_blankline) do
                ['http://lc/te/1', '', 'http://lc/te/2'].map { |i| i.blank? ? '' : "#{valid_prefix}#{i}" }
              end

              it 'returns parsed URI' do
                expect(lc.plain(one_uri)).to include(URI.parse(one_uri.first.gsub(valid_prefix, '')))
              end

              it 'returns multiple parsed URIs' do
                expect(lc.plain(two_uris).count).to eq 2
              end

              it 'skips blank lines' do
                expect(lc.plain(with_blankline).count).to eq 2
              end
            end

            context 'with invalid URIs' do
              let(:invalid_uri) { ['X-OCCI-Location: blaba blaABLA ASLDKASD'] }
              let(:invalid_prefix) { ['Location: http://local/loc/1'] }

              it 'fails with invalid URI' do
                expect { lc.plain(invalid_uri) }.to raise_error(Occi::Core::Errors::ParsingError)
              end

              it 'fails with invalid prefix' do
                expect { lc.plain(invalid_prefix) }.to raise_error(Occi::Core::Errors::ParsingError)
              end
            end
          end

          describe '::uri_list' do
            context 'without input' do
              it 'fails for `nil`' do
                expect { lc.uri_list(nil) }.to raise_error(NoMethodError)
              end

              it 'returns empty array for empty enumerable' do
                expect(lc.uri_list([])).to be_empty
              end
            end

            context 'with valid URIs' do
              let(:one_uri) { ['http://localhost/test/something/1'] }
              let(:two_uris) do
                ['http://localhost/te/2', 'http://localhost/st/3']
              end
              let(:with_blankline) do
                ['http://lc/te/1', '', 'http://lc/te/2']
              end

              it 'returns parsed URI' do
                expect(lc.uri_list(one_uri)).to include(URI.parse(one_uri.first))
              end

              it 'returns multiple parsed URIs' do
                expect(lc.uri_list(two_uris).count).to eq 2
              end

              it 'skips blank lines' do
                expect(lc.uri_list(with_blankline).count).to eq 2
              end
            end

            context 'with invalid URIs' do
              let(:invalid_uri) { ['blaba blaABLA ASLDKASD'] }

              it 'fails with InvalidURIError' do
                expect { lc.uri_list(invalid_uri) }.to raise_error(URI::InvalidURIError)
              end
            end
          end
        end
      end
    end
  end
end
