module Occi
  module Core
    module Renderers
      module Text
        describe Model do
          subject(:modr) { model_renderer }

          let(:example_term) { 'kind' }
          let(:example_schema) { 'http://schemas.org/schema#' }
          let(:example_title) { 'Generic kind' }

          let(:attribute_name) { 'occi.core.test' }
          let(:attribute_def) { Occi::Core::AttributeDefinition.new(required: true, mutable: false) }
          let(:attributes) { { attribute_name => attribute_def } }

          let(:root_kind) do
            Occi::Core::Kind.new(
              term: 'root', schema: 'http://test.org/root#',
              title: 'Root kind'
            )
          end

          let(:kind) do
            Occi::Core::Kind.new(
              term: example_term, schema: example_schema,
              title: example_title, parent: root_kind,
              attributes: attributes
            )
          end

          let(:action) do
            Occi::Core::Action.new(term: 'action', schema: example_schema)
          end

          let(:second_mixin) do
            Occi::Core::Mixin.new(
              term: "mixin_#{example_term}2",
              schema: example_schema,
              title: example_title
            )
          end

          let(:mixin) do
            Occi::Core::Mixin.new(
              term: "mixin_#{example_term}1", schema: example_schema,
              title: example_title, depends: Set.new([second_mixin]),
              applies: Set.new([kind]), actions: Set.new([action]),
              attributes: attributes
            )
          end

          let(:model) do
            m = Occi::Core::Model.new
            m << root_kind << kind << action << mixin << second_mixin
          end
          let(:empty_model) { Occi::Core::Model.new }

          let(:options) { { format: 'text' } }
          let(:model_renderer) { Model.new(model, options) }
          let(:empty_model_renderer) { Model.new(empty_model, options) }

          BASE_ATTRS = %i(object options).freeze
          BASE_ATTRS.each do |attr|
            it "has #{attr} accessor" do
              is_expected.to have_attr_accessor attr.to_sym
            end
          end

          it 'has logger' do
            expect(modr).to respond_to(:logger)
            expect(modr.class).to respond_to(:logger)
          end

          describe '#render' do
            context 'with unknown format' do
              before do
                modr.options = { format: 'unknown' }
              end

              it 'raises error' do
                expect { modr.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end
            end

            context 'with `text` format' do
              it 'renders' do
                expect { modr.render }.not_to raise_error
              end
            end

            context 'with `headers` format' do
              before do
                modr.options = { format: 'headers' }
              end

              it 'renders' do
                expect { modr.render }.not_to raise_error
              end
            end

            context 'with empty model' do
              it 'renders' do
                expect { empty_model_renderer.render }.not_to raise_error
              end
            end
          end
        end
      end
    end
  end
end
