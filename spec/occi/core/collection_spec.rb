module Occi
  module Core
    describe Collection do
      subject(:coll) { collection }
      let(:collection) { Collection.new }

      COLL_ATTRS = [:categories, :entities, :action_instances].freeze

      COLL_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has logger' do
        expect(coll).to respond_to(:logger)
        expect(coll.class).to respond_to(:logger)
      end
    end
  end
end
