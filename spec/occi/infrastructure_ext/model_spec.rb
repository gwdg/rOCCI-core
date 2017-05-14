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

      describe '#find_availability_zones' do
        before do
          model.load_core!
          model.load_infrastructure!
          model.load_infrastructure_ext!
        end

        context 'without availability_zone mixins' do
          it 'returns empty collection' do
            expect(model.find_availability_zones).to be_empty
          end
        end

        context 'with availability_zone mixins' do
          let(:availability_zone_base) { Occi::InfrastructureExt::Mixins::AvailabilityZone.new }
          let(:availability_zone) do
            Occi::Core::Mixin.new(
              term: 'test',
              schema: 'http://test/1#',
              depends: Set.new([availability_zone_base])
            )
          end

          before { model << availability_zone }

          it 'returns only availability_zone mixins' do
            expect(model.find_availability_zones).to include(availability_zone)
          end
        end
      end
    end
  end
end
