module Occi
  module Core
    module Renderers
      module Text
        describe Category do
          subject(:cat) { category_renderer }

          let(:example_term) { 'kind' }
          let(:example_schema) { 'http://schemas.org/schema#' }
          let(:example_title) { 'Generic kind' }

          let(:root_kind) do
            Kind.new(
              term: 'root',
              schema: 'http://test.org/root#',
              title: 'Root kind'
            )
          end

          let(:kind) do
            Kind.new(
              term: example_term,
              schema: example_schema,
              title: example_title,
              parent: root_kind
            )
          end

          let(:options) { { format: 'text' } }
          let(:category_renderer) { Category.new(kind, options) }

          BASE_ATTRS = [:object, :options].freeze

          BASE_ATTRS.each do |attr|
            it "has #{attr} accessor" do
              is_expected.to have_attr_accessor attr.to_sym
            end
          end

          it 'has logger' do
            expect(cat).to respond_to(:logger)
            expect(cat.class).to respond_to(:logger)
          end

          describe '#render' do
            context 'with unknown format' do
              before(:example) do
                cat.options = { format: 'unknown' }
              end

              it 'raises error' do
                expect { cat.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end
            end

            context 'with `text` format' do
              it 'renders' do
                expect { cat.render }.not_to raise_error
              end
            end

            context 'with `headers` format' do
              before(:example) do
                cat.options = { format: 'headers' }
              end

              it 'renders' do
                expect { cat.render }.not_to raise_error
              end
            end
          end
        end
      end
    end
  end
end
