module Occi
  module Core
    module Renderers
      module Text
        describe ActionInstance do
          subject(:trai) { ActionInstance.new(ai, options) }

          let(:example_term) { 'action' }
          let(:example_schema) { 'http://schemas.org/schema#' }
          let(:example_title) { 'Generic action' }
          let(:attr_def) { Occi::Core::AttributeDefinition.new }
          let(:example_attributes) { { 'test' => attr_def } }

          let(:action) do
            Occi::Core::Action.new(
              term: example_term, schema: example_schema,
              title: example_title, attributes: example_attributes
            )
          end

          let(:attrs) { { 'test' => Occi::Core::Attribute.new('my_test_attribute', nil) } }
          let(:ai) do
            Occi::Core::ActionInstance.new(action: action, attributes: attrs)
          end

          context 'with text format' do
            let(:options) { { format: 'text' } }

            it 'renders with action' do
              expect(trai.render).to include('Category: ')
            end

            it 'renders with attributes' do
              expect(trai.render).to include('X-OCCI-Attribute: ')
            end
          end

          context 'with headers format' do
            let(:options) { { format: 'headers' } }

            it 'renders with action' do
              expect(trai.render).to include('X-OCCI-Category')
            end

            it 'renders with attributes' do
              expect(trai.render).to include('X-OCCI-Attribute')
            end
          end
        end
      end
    end
  end
end
