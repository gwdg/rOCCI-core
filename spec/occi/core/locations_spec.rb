module Occi
  module Core
    describe Locations do
      subject(:locs) { locations }

      let(:locations) { Locations.new }

      LOCS_ATTRS = %i[uris].freeze

      LOCS_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has logger' do
        expect(locs).to respond_to(:logger)
        expect(locs.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(locs).to be_kind_of(Helpers::Renderable)
        expect(locs).to respond_to(:render)
      end

      it 'is enumerable' do
        expect(locs).to be_kind_of(Enumerable)
        expect(locs).to respond_to(:each)
      end
    end
  end
end
