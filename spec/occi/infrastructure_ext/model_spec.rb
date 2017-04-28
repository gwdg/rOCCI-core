module Occi
  module InfrastructureExt
    describe Model do
      subject { model }

      let(:model) { Occi::InfrastructureExt::Model.new }

      describe '#load_infrastructure_ext!' do
        context 'without Infra specs' do
          it 'fails to load InfraExt specs' do
            expect { model.load_infrastructure_ext! }.to raise_error(Occi::Core::Errors::ModelLookupError)
          end
        end

        context 'with Infra specs' do
          before do
            model.load_core!
            model.load_infrastructure!
          end

          it 'loads InfraExt specs' do
            expect { model.load_infrastructure_ext! }.not_to raise_error
          end
        end
      end

      describe '#instance_builder' do
        it 'returns IB instance' do
          expect(model.instance_builder).to be_kind_of Occi::InfrastructureExt::InstanceBuilder
        end
      end
    end
  end
end
