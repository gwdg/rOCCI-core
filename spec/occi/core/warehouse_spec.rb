module Occi
  module Core
    describe Warehouse do
      subject { warehouse }

      let(:warehouse) { Occi::Core::Warehouse }
      let(:model) { Occi::Core::Model.new }

      describe '::bootstrap!' do
        it 'loads Core specs' do
          expect(model.empty?).to be true
          expect { warehouse.bootstrap! model }.not_to raise_error
          expect(model.empty?).to be false
        end
      end
    end
  end
end
