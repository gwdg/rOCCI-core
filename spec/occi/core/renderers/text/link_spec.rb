module Occi
  module Core
    module Renderers
      module Text
        describe Link do
          subject(:trlink) { Link.new(link, options) }

          let(:attribute_title) { 'occi.core.title' }
          let(:attribute_id) { 'occi.core.id' }
          let(:attribute_source) { 'occi.core.source' }
          let(:attribute_target) { 'occi.core.target' }
          let(:attr_defn_string) { Occi::Core::AttributeDefinition.new }

          let(:example_term) { 'lkind' }
          let(:example_schema) { 'http://schemas.org/schema#' }
          let(:example_title) { 'Generic link kind' }

          let(:attributes) do
            {
              attribute_title   => attr_defn_string,
              attribute_id      => attr_defn_string,
              attribute_source  => attr_defn_string,
              attribute_target  => attr_defn_string
            }
          end

          let(:mixin) do
            Occi::Core::Mixin.new(
              term: 'second_mixin',
              schema: 'http://schema.test.opr/test#',
              title: 'Second mixin'
            )
          end
          let(:mixins) { Set.new([mixin]) }

          let(:kind) do
            Occi::Core::Kind.new(
              term: example_term,
              schema: example_schema,
              title: example_title,
              attributes: attributes
            )
          end

          let(:link) { Occi::Core::Link.new(kind: kind, title: 'My Link', mixins: mixins) }

          context 'with text format' do
            let(:options) { { format: 'text' } }

            it 'renders with kind' do
              expect(trlink.render).to include 'class="kind"'
            end

            it 'renders with mixins' do
              expect(trlink.render).to include 'class="mixin"'
            end

            it 'renders with attributes' do
              expect(trlink.render).to include 'X-OCCI-Attribute'
            end
          end

          context 'with headers format' do
            let(:options) { { format: 'headers' } }

            it 'renders with kind and mixins' do
              expect(trlink.render).to include 'X-OCCI-Category'
            end

            it 'renders with attributes' do
              expect(trlink.render).to include 'X-OCCI-Attribute'
            end
          end
        end
      end
    end
  end
end
