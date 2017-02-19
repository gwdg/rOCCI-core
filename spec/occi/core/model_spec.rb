module Occi
  module Core
    describe Model do
      subject(:mdl) { model }
      let(:model) { Model.new }

      let(:example_term) { 'kind' }
      let(:example_schema) { 'http://schemas.org/schema#' }
      let(:example_title) { 'Generic kind' }

      let(:attribute_title) { 'occi.core.title' }
      let(:attribute_id) { 'occi.core.id' }
      let(:attribute_source) { 'occi.core.source' }
      let(:attribute_target) { 'occi.core.target' }
      let(:attributes) do
        {
          attribute_title   => instance_double('Occi::Core::AttributeDefinition'),
          attribute_id      => instance_double('Occi::Core::AttributeDefinition'),
          attribute_source  => instance_double('Occi::Core::AttributeDefinition'),
          attribute_target  => instance_double('Occi::Core::AttributeDefinition')
        }
      end

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

      let(:mixin) do
        Mixin.new(
          term: 'mixin',
          schema: example_schema,
          title: 'Mixin',
          applies: [kind]
        )
      end

      let(:action) do
        Action.new(
          schema: example_schema,
          term: 'action',
          title: 'Action'
        )
      end

      before do
        attributes.keys.each do |attrib|
          allow(attributes[attrib]).to receive(:default)
          allow(attributes[attrib]).to receive(:valid!)
        end

        mdl << kind << action << mixin << root_kind
      end

      it 'has logger' do
        expect(mdl).to respond_to(:logger)
        expect(mdl.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(mdl).to be_kind_of(Helpers::Renderable)
        expect(mdl).to respond_to(:render)
      end

      describe '#valid!' do
        it 'does something'
      end

      describe '#valid?' do
        it 'does something'
      end
    end
  end
end
