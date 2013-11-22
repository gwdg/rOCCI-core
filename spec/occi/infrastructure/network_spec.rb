module Occi
  module Infrastructure
    describe Network do

      context 'setters/getters' do
        let(:network){ Occi::Infrastructure::Network.new }
        context '#vlan' do
          it 'Can be set and read as attribute' do
            network.vlan = 4
            expect(network.attributes.occi.network.vlan).to eql 4
          end

          it 'Can be set and read through getter' do
            network.vlan = 4
            expect(network.vlan).to eql 4
          end
        end

        context '#label' do
          it 'Can be set and read as attribute' do
            network.label = "Network Label"
            expect(network.attributes.occi.network.label).to eql "Network Label"
          end

          it 'Can be set and read through getter' do
            network.label = "Network Label"
            expect(network.label).to eql "Network Label"
          end
        end

        context '#state' do
          it 'Can be set and read as attribute' do
            network.state = "inactive"
            expect(network.attributes.occi.network.state).to eql "inactive"
          end

          it 'Can be set and read through getter' do
            network.state = "inactive"
            expect(network.state).to eql "inactive"
          end
        end

        context '#address' do
          it 'Can be set and read as attribute' do
            network.address = "127.0.0.1"
            expect(network.attributes.occi.network.address).to eql "127.0.0.1"
          end

          it 'Can be set and read through getter' do
            network.address = "127.0.0.1"
            expect(network.address).to eql "127.0.0.1"
          end
        end

        context '#gateway' do
          it 'Can be set and read as attribute' do
            network.gateway = "127.0.0.255"
            expect(network.attributes.occi.network.gateway).to eql "127.0.0.255"
          end

          it 'Can be set and read through getter' do
            network.gateway = "127.0.0.255"
            expect(network.gateway).to eql "127.0.0.255"
          end
        end

        context '#allocation' do
          it 'Can be set and read as attribute' do
            network.allocation = "static"
            expect(network.attributes.occi.network.allocation).to eql "static"
          end

          it 'Can be set and read through getter' do
            network.allocation = "static"
            expect(network.allocation).to eql "static"
          end
        end
      end

      context '#ipnetwork' do
        let(:network){ Occi::Infrastructure::Network.new }

        it 'adds the Ipnetwork mixin' do
          network.ipnetwork(true)
          expect(network.mixins.first.to_s).to eql "http://schemas.ogf.org/occi/infrastructure/network#ipnetwork"
        end

        it 'removes the Ipnetwork mixin' do
          network.ipnetwork(true)
          network.ipnetwork(false)
          expect(network.mixins.count).to eql 0
        end
      end
    end
  end
end
