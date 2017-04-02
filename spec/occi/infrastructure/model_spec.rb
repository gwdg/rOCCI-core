module Occi
  module Infrastructure
    describe Model do
      subject { model }
      let(:model) { Occi::Infrastructure::Model.new }

      describe '#load_infrastructure!' do
        context 'without Core specs' do
          it 'fails to load Infra specs' do
            expect { model.load_infrastructure! }.to raise_error(RuntimeError)
          end
        end

        context 'with Core specs' do
          before { model.load_core! }

          it 'loads Infra specs' do
            expect { model.load_infrastructure! }.not_to raise_error
          end
        end
      end
    end
  end
end
