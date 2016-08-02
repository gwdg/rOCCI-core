module Occi
  module Core
    describe Entity do
      subject { entity }

      let(:kind) do
        Kind.new(
          term: 'root',
          schema: 'http://test.org/root#',
          title: 'Root kind'
        )
      end
      let(:entity) do
        Entity.new(kind: kind)
      end

      ENTITY_ATTRS = [:kind, :id, :location, :title, :attributes, :mixins, :actions].freeze

      ENTITY_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has attributes value accessor' do
        expect(subject).to be_kind_of(Helpers::AttributesAccessor)
        expect(subject).to respond_to(:[])
        expect(subject).to respond_to(:[]=)
      end

      it 'has logger' do
        expect(subject).to respond_to(:logger)
        expect(subject.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(subject).to be_kind_of(Helpers::Renderable)
        expect(subject).to respond_to(:render)
      end
    end
  end
end
