module Occi
  module Infrastructure
    describe Warehouse do
      subject { warehouse }
      let(:c_warehouse) { Occi::Core::Warehouse }
      let(:warehouse) { Occi::Infrastructure::Warehouse }
      let(:model) { Occi::Infrastructure::Model.new }

      describe '::bootstrap!' do
        context 'with Core specs loaded' do
          before { c_warehouse.bootstrap! model }

          it 'loads Infra specs' do
            expect { warehouse.bootstrap! model }.not_to raise_error
          end
        end

        context 'without Core specs loaded' do
          it 'fails to load Infra specs' do
            expect { warehouse.bootstrap! model }.to raise_error(RuntimeError)
          end
        end
      end
    end
  end
end
