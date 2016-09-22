module Occi
  module Core
    module Renderers
      module Text
        describe Resource do
          subject(:trres) { Resource.new(resource, options) }

          let(:attribute_title) { 'occi.core.title' }
          let(:attribute_id) { 'occi.core.id' }
          let(:attribute_source) { 'occi.core.source' }
          let(:attribute_target) { 'occi.core.target' }
          let(:attr_defn_string) { Occi::Core::AttributeDefinition.new }

          let(:example_term) { 'lkind' }
          let(:example_schema) { 'http://schemas.org/schema#' }
          let(:example_title) { 'Generic link kind' }

          let(:lnk_attributes) do
            {
              attribute_title   => attr_defn_string,
              attribute_id      => attr_defn_string,
              attribute_source  => attr_defn_string,
              attribute_target  => attr_defn_string
            }
          end

          let(:attributes) do
            {
              attribute_title   => attr_defn_string,
              attribute_id      => attr_defn_string
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

          let(:lnk_kind) do
            Occi::Core::Kind.new(
              term: example_term,
              schema: example_schema,
              title: example_title,
              attributes: lnk_attributes
            )
          end

          let(:kind) do
            Occi::Core::Kind.new(
              term: example_term.gsub('l', 'res'),
              schema: example_schema,
              title: example_title.gsub('link', 'resource'),
              attributes: attributes
            )
          end

          let(:link) { Occi::Core::Link.new(kind: lnk_kind, title: 'My Link', mixins: mixins) }
          let(:resource) { Occi::Core::Resource.new(kind: kind, title: 'My Resource', mixins: mixins) }
          let(:resource2) { Occi::Core::Resource.new(kind: kind, title: 'My Resource 2', mixins: mixins) }
          let(:action) { Occi::Core::Action.new(term: 'action', schema: example_schema) }

          context 'with text format' do
            let(:options) { { format: 'text' } }

            it 'renders with kind' do
              expect(trres.render).to include 'class="kind"'
            end

            it 'renders with mixins' do
              expect(trres.render).to include 'class="mixin"'
            end

            it 'renders with attributes' do
              expect(trres.render).to include 'X-OCCI-Attribute'
            end

            it 'renders with link' do
              link.target = resource2
              resource.links << link
              expect(trres.render).to include 'Link'
            end

            it 'renders with action' do
              resource.actions << action
              expect(trres.render).to include 'Link'
            end
          end

          context 'with headers format' do
            let(:options) { { format: 'headers' } }

            it 'renders with kind and mixins' do
              expect(trres.render).to include 'X-OCCI-Category'
            end

            it 'renders with attributes' do
              expect(trres.render).to include 'X-OCCI-Attribute'
            end

            it 'renders with link' do
              link.target = resource2
              resource.links << link
              expect(trres.render).to include 'Link'
            end

            it 'renders with action' do
              resource.actions << action
              expect(trres.render).to include 'Link'
            end
          end
        end
      end
    end
  end
end
