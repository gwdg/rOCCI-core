module Occi
  module Core
    describe Link do
      subject(:lnk) { link }

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

      let(:kind) { instance_double('Occi::Core::Kind') }

      let(:link) { Link.new(kind: kind, title: 'My Link') }

      before(:example) do
        allow(kind).to receive(:attributes).and_return(attributes)
        attributes.keys.each { |attrib| allow(attributes[attrib]).to receive(:default) }
      end

      LNK_ATTRS = [:source, :target].freeze

      LNK_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has attributes value accessor' do
        expect(lnk).to be_kind_of(Helpers::InstanceAttributesAccessor)
        expect(lnk).to respond_to(:[])
        expect(lnk).to respond_to(:[]=)
        expect(lnk).to respond_to(:attribute?)
      end

      it 'has logger' do
        expect(lnk).to respond_to(:logger)
        expect(lnk.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(lnk).to be_kind_of(Helpers::Renderable)
        expect(lnk).to respond_to(:render)
      end

      describe '#source'
      describe '#source='
      describe '#target'
      describe '#target='
      describe '#rel'
    end
  end
end
