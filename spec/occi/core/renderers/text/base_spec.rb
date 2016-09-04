module Occi
  module Core
    module Renderers
      module Text
        describe Base do
          subject(:bse) { base_renderer }

          let(:category) { instance_double('Occi::Core::Category') }
          let(:options) { { format: 'text' } }
          let(:base_renderer) { Base.new(category, options) }

          BASE_ATTRS = [:object, :options].freeze

          BASE_ATTRS.each do |attr|
            it "has #{attr} accessor" do
              is_expected.to have_attr_accessor attr.to_sym
            end
          end

          it 'has logger' do
            expect(bse).to respond_to(:logger)
            expect(bse.class).to respond_to(:logger)
          end

          describe '::new' do
            it 'assigns `object`' do
              expect(bse.object).to be category
            end

            it 'assigns `options`' do
              expect(bse.options).to be options
            end
          end

          describe '#render' do
            context 'with unknown format' do
              before(:example) do
                bse.options = { format: 'unknown' }
              end

              it 'raises error' do
                expect { bse.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end
            end

            context 'with `text` format' do
              it 'renders' do
                expect { bse.render }.not_to raise_error
              end
            end

            context 'with `headers` format' do
              before(:example) do
                bse.options = { format: 'headers' }
              end

              it 'renders' do
                expect { bse.render }.not_to raise_error
              end
            end
          end

          describe '#render_safe' do
            it 'returns integer' do
              expect(bse.render_safe).to be_kind_of(Integer)
            end
          end

          describe '#render_plain' do
            it 'does not do anything' do
              expect(bse.render_plain).to be nil
            end
          end

          describe '#render_headers' do
            it 'does not do anything' do
              expect(bse.render_headers).to be nil
            end
          end
        end
      end
    end
  end
end
