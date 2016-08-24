module Occi
  module Core
    describe Resource do
      subject(:res) { resource }

      let(:attribute_title) { 'occi.core.title' }
      let(:attribute_id) { 'occi.core.id' }
      let(:attribute_summary) { 'occi.core.summary' }
      let(:attributes) do
        {
          attribute_title   => instance_double('Occi::Core::AttributeDefinition'),
          attribute_id      => instance_double('Occi::Core::AttributeDefinition'),
          attribute_summary => instance_double('Occi::Core::AttributeDefinition')
        }
      end

      let(:kind) { instance_double('Occi::Core::Kind') }

      let(:resource) { Resource.new(kind: kind, title: 'My Resource') }

      before(:example) do
        allow(kind).to receive(:attributes).and_return(attributes)
        attributes.keys.each { |attrib| allow(attributes[attrib]).to receive(:default) }
      end

      RES_ATTRS = [:summary].freeze

      RES_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has attributes value accessor' do
        expect(res).to be_kind_of(Helpers::InstanceAttributesAccessor)
        expect(res).to respond_to(:[])
        expect(res).to respond_to(:[]=)
        expect(res).to respond_to(:attribute?)
      end

      it 'has logger' do
        expect(res).to respond_to(:logger)
        expect(res.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(res).to be_kind_of(Helpers::Renderable)
        expect(res).to respond_to(:render)
      end

      describe '#summary'
      describe '#summary='
      describe '#links='
      describe '#<<'
      describe '#remove'
      describe '#add_link'
      describe '#remove_link'
    end
  end
end
