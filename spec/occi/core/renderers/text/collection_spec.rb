module Occi
  module Core
    module Renderers
      module Text
        describe Collection do
          subject(:collr) { empty_collection_renderer }

          let(:example_term) { 'kind' }
          let(:example_schema) { 'http://schemas.org/schema#' }
          let(:example_title) { 'Generic kind' }

          let(:attribute_name_id) { 'occi.core.id' }
          let(:attribute_name_title) { 'occi.core.title' }
          let(:attribute_def) { Occi::Core::AttributeDefinition.new(required: true, mutable: true) }
          let(:rattribute_def) { Occi::Core::AttributeDefinition.new(required: true, type: Occi::Core::Resource) }
          let(:attributes) { { attribute_name_id => attribute_def, attribute_name_title => attribute_def } }
          let(:lattributes) do
            attributes['occi.core.source'] = rattribute_def
            attributes['occi.core.target'] = attribute_def
            attributes
          end
          let(:aatributes) do
            { 'method' => attribute_def }
          end

          let(:empty_collection) { Occi::Core::Collection.new }
          let(:options) { { format: 'text' } }
          let(:empty_collection_renderer) { Collection.new(empty_collection, options) }

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

          let(:lkind) do
            Occi::Core::Kind.new(
              term: example_term, schema: example_schema,
              title: example_title, parent: root_kind,
              attributes: lattributes
            )
          end

          let(:action) do
            Occi::Core::Action.new(
              term: 'action', schema: example_schema,
              attributes: aatributes
            )
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

          let(:resource) do
            r = Occi::Core::Resource.new(kind: kind, title: 'My Resource')
            r.identify!
            r
          end

          let(:link) do
            l = Occi::Core::Link.new(kind: lkind, title: 'My Resource')
            l.source = resource
            l.target = 'http://well/meh/here'
            l.identify!
            l
          end

          let(:action_instance) do
            ai = Occi::Core::ActionInstance.new(action: action)
            ai['method'] = 'warm'
            ai
          end

          BASE_ATTRS = %i(object options).freeze
          BASE_ATTRS.each do |attr|
            it "has #{attr} accessor" do
              is_expected.to have_attr_accessor attr.to_sym
            end
          end

          it 'has logger' do
            expect(empty_collection_renderer).to respond_to(:logger)
            expect(empty_collection_renderer.class).to respond_to(:logger)
          end

          describe '#render' do
            context 'with unknown format' do
              before do
                empty_collection_renderer.options = { format: 'unknown' }
              end

              it 'raises error' do
                expect { empty_collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end
            end

            context 'with `text` format' do
              it 'renders' do
                expect { empty_collection_renderer.render }.not_to raise_error
              end
            end

            context 'with `headers` format' do
              before do
                empty_collection_renderer.options = { format: 'headers' }
              end

              it 'renders' do
                expect { empty_collection_renderer.render }.not_to raise_error
              end
            end

            context 'with empty collection' do
              it 'renders' do
                expect { empty_collection_renderer.render }.not_to raise_error
              end
            end

            context '`headers` with categories' do
              let(:collection) do
                empty_collection << root_kind << kind << mixin << second_mixin << action
              end
              let(:collection_renderer) do
                empty_collection_renderer.object = collection
                empty_collection_renderer.options = { format: 'headers' }
                empty_collection_renderer
              end

              it 'renders without error' do
                expect { collection_renderer.render }.not_to raise_error
              end

              it 'renders category lines' do
                rlines = collection_renderer.render
                expect(rlines.values.first).to be_kind_of Enumerable
                expect(rlines.values.first.count).to eq 5
                expect(rlines.keys.count).to eq 1
                expect(rlines.keys.first).to eq 'X-OCCI-Category'
              end
            end

            context '`text` with categories' do
              let(:collection) do
                empty_collection << root_kind << kind << mixin << second_mixin << action
              end
              let(:collection_renderer) do
                empty_collection_renderer.object = collection
                empty_collection_renderer
              end

              it 'renders without error' do
                expect { collection_renderer.render }.not_to raise_error
              end

              it 'renders category lines' do
                rlines = collection_renderer.render
                expect(rlines).to be_kind_of String
                expect(rlines.lines.count).to eq 5
                expect(rlines.lines).to all(start_with('Category: '))
              end
            end

            context '`headers` with resource' do
              let(:collection) do
                empty_collection << resource
              end
              let(:collection_renderer) do
                empty_collection_renderer.object = collection
                empty_collection_renderer.options = { format: 'headers' }
                empty_collection_renderer
              end

              it 'renders without error' do
                expect { collection_renderer.render }.not_to raise_error
              end

              it 'renders entitiy sub-type instance' do
                rndr = collection_renderer.render
                expect(rndr.keys).to eq ['X-OCCI-Category', 'X-OCCI-Attribute', 'X-OCCI-Link']
                expect(rndr['X-OCCI-Category']).not_to be_empty
                expect(rndr['X-OCCI-Attribute']).not_to be_empty
                expect(rndr['X-OCCI-Link']).to be_empty
              end
            end

            context '`text` with resource' do
              let(:collection) do
                empty_collection << resource
              end
              let(:collection_renderer) do
                empty_collection_renderer.object = collection
                empty_collection_renderer
              end

              it 'renders without error' do
                expect { collection_renderer.render }.not_to raise_error
              end

              it 'renders entitiy sub-type instance' do
                rndr = collection_renderer.render
                expect(rndr).to include 'Category: '
                expect(rndr).to include 'X-OCCI-Attribute: '
              end
            end

            context '`headers` with link' do
              let(:collection) do
                empty_collection << link
              end
              let(:collection_renderer) do
                empty_collection_renderer.object = collection
                empty_collection_renderer.options = { format: 'headers' }
                empty_collection_renderer
              end

              it 'renders without error' do
                expect { collection_renderer.render }.not_to raise_error
              end

              it 'renders entitiy sub-type instance' do
                rndr = collection_renderer.render
                expect(rndr.keys).to eq ['X-OCCI-Category', 'X-OCCI-Attribute']
                expect(rndr['X-OCCI-Category']).not_to be_empty
                expect(rndr['X-OCCI-Attribute']).not_to be_empty
              end
            end

            context '`text` with link' do
              let(:collection) do
                empty_collection << link
              end
              let(:collection_renderer) do
                empty_collection_renderer.object = collection
                empty_collection_renderer
              end

              it 'renders without error' do
                expect { collection_renderer.render }.not_to raise_error
              end

              it 'renders entitiy sub-type instance' do
                rndr = collection_renderer.render
                expect(rndr).to include 'Category: '
                expect(rndr).to include 'X-OCCI-Attribute: '
              end
            end

            context '`headers` with action instances' do
              let(:collection) do
                empty_collection << action_instance
              end
              let(:collection_renderer) do
                empty_collection_renderer.object = collection
                empty_collection_renderer.options = { format: 'headers' }
                empty_collection_renderer
              end

              it 'renders without error' do
                expect { collection_renderer.render }.not_to raise_error
              end

              it 'renders entitiy sub-type instance' do
                rndr = collection_renderer.render
                expect(rndr.keys).to eq ['X-OCCI-Category', 'X-OCCI-Attribute']
                expect(rndr['X-OCCI-Category']).not_to be_empty
                expect(rndr['X-OCCI-Attribute']).not_to be_empty
              end
            end

            context '`text` with action instances' do
              let(:collection) do
                empty_collection << action_instance
              end
              let(:collection_renderer) do
                empty_collection_renderer.object = collection
                empty_collection_renderer
              end

              it 'renders without error' do
                expect { collection_renderer.render }.not_to raise_error
              end

              it 'renders entitiy sub-type instance' do
                rndr = collection_renderer.render
                expect(rndr).to include 'Category'
                expect(rndr).to include 'X-OCCI-Attribute'
              end
            end

            context '`headers` with mixed content' do
              let(:ai_r_collection) { empty_collection << action_instance << resource }
              let(:r_l_collection) { empty_collection << link << resource }
              let(:c_r_collection) { empty_collection << kind << root_kind << resource }
              let(:c_ai_collection) { empty_collection << action_instance << kind << root_kind }
              let(:collection_renderer) do
                empty_collection_renderer.options = { format: 'headers' }
                empty_collection_renderer
              end

              it 'raises error when combining AI and entity sub-type instance' do
                collection_renderer.object = ai_r_collection
                expect { collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end

              it 'raises error when combining two entity sub-type instances' do
                collection_renderer.object = r_l_collection
                expect { collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end

              it 'raises error when combining Category and entity sub-type instance' do
                collection_renderer.object = c_r_collection
                expect { collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end

              it 'raises error when combining AI and Category' do
                collection_renderer.object = c_ai_collection
                expect { collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end
            end

            context '`text` with mixed content' do
              let(:ai_r_collection) { empty_collection << action_instance << resource }
              let(:r_l_collection) { empty_collection << link << resource }
              let(:c_r_collection) { empty_collection << kind << root_kind << resource }
              let(:c_ai_collection) { empty_collection << action_instance << kind << root_kind }
              let(:collection_renderer) { empty_collection_renderer }

              it 'raises error when combining AI and entity sub-type instance' do
                collection_renderer.object = ai_r_collection
                expect { collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end

              it 'raises error when combining two entity sub-type instances' do
                collection_renderer.object = r_l_collection
                expect { collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end

              it 'raises error when combining Category and entity sub-type instance' do
                collection_renderer.object = c_r_collection
                expect { collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end

              it 'raises error when combining AI and Category' do
                collection_renderer.object = c_ai_collection
                expect { collection_renderer.render }.to raise_error(Occi::Core::Errors::RenderingError)
              end
            end
          end
        end
      end
    end
  end
end
