module Occi
  module InfrastructureExt
    describe Warehouse do
      subject { warehouse }

      let(:c_warehouse) { Occi::Core::Warehouse }
      let(:i_warehouse) { Occi::Infrastructure::Warehouse }
      let(:warehouse) { Occi::InfrastructureExt::Warehouse }
      let(:model) { Occi::InfrastructureExt::Model.new }

      describe '::bootstrap!' do
        context 'with Core specs loaded' do
          before do
            c_warehouse.bootstrap! model
            i_warehouse.bootstrap! model
          end

          it 'loads InfraExt specs' do
            expect { warehouse.bootstrap! model }.not_to raise_error
          end
        end

        context 'without Infra specs loaded' do
          before { c_warehouse.bootstrap! model }

          it 'fails to load InfraExt specs' do
            expect { warehouse.bootstrap! model }.to raise_error(Occi::Core::Errors::ModelLookupError)
          end
        end
      end
    end
  end
end
