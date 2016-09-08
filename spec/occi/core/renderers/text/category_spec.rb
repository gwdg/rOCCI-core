module Occi
  module Core
    module Renderers
      module Text
        describe Category do
          subject(:cat) { kind_renderer }

          let(:example_term) { 'kind' }
          let(:example_schema) { 'http://schemas.org/schema#' }
          let(:example_title) { 'Generic kind' }

          let(:attribute_name) { 'occi.core.test' }
          let(:attribute_def) { Occi::Core::AttributeDefinition.new(required: true, mutable: false) }
          let(:attributes) { { attribute_name => attribute_def } }

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
              parent: root_kind,
              attributes: attributes
            )
          end

          let(:options) { { format: 'text' } }
          let(:kind_renderer) { Category.new(kind, options) }
          let(:mixin_renderer) { Category.new(mixin, options) }
          let(:action_renderer) { Category.new(action, options) }

          let(:action) do
            Occi::Core::Action.new(term: 'action', schema: example_schema)
          end

          let(:second_mixin) do
            Mixin.new(
              term: "mixin_#{example_term}2",
              schema: example_schema,
              title: example_title
            )
          end

          let(:mixin) do
            Mixin.new(
              term: "mixin_#{example_term}1",
              schema: example_schema,
              title: example_title,
              depends: Set.new([second_mixin]),
              applies: Set.new([kind]),
              actions: Set.new([action]),
              attributes: attributes
            )
          end

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

          describe '::category_key_plain' do
            it 'returns a category string' do
              expect(Category.category_key_plain).to eq 'Category'
            end
          end

          describe '::category_key_headers' do
            it 'returns a category string' do
              expect(Category.category_key_headers).to eq 'X-OCCI-Category'
            end
          end

          describe '#category_key_plain' do
            it 'returns a category string' do
              expect(cat.category_key_plain).to eq 'Category'
            end
          end

          describe '#category_key_headers' do
            it 'returns a category string' do
              expect(cat.category_key_headers).to eq 'X-OCCI-Category'
            end
          end

          describe '#render' do
            context 'with unknown format' do
              before do
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
              before do
                cat.options = { format: 'headers' }
              end

              it 'renders' do
                expect { cat.render }.not_to raise_error
              end
            end

            context 'with mixin' do
              it 'renders' do
                expect { mixin_renderer.render }.not_to raise_error
              end
            end

            context 'with action' do
              it 'renders' do
                expect { action_renderer.render }.not_to raise_error
              end
            end
          end
        end
      end
    end
  end
end
