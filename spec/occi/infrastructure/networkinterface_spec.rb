module Occi
  module Infrastructure
    describe Networkinterface do

      context 'setters/getters' do
        let(:networkinterface){ Occi::Infrastructure::Networkinterface.new }
        context '#interface' do
          it 'Can be set and read as attribute' do
            networkinterface.interface = "eth0"
            expect(networkinterface.attributes.occi.networkinterface.interface).to eql "eth0"
          end

          it 'Can be set and read through getter' do
            networkinterface.interface = "eth0"
            expect(networkinterface.interface).to eql "eth0"
          end
        end

        context '#mac' do
          it 'Can be set and read as attribute' do
            networkinterface.mac = "FF-FF-FF-FF-FF-FF"
            expect(networkinterface.attributes.occi.networkinterface.mac).to eql "FF-FF-FF-FF-FF-FF"
          end

          it 'Can be set and read through getter' do
            networkinterface.mac = "FF-FF-FF-FF-FF-FF"
            expect(networkinterface.mac).to eql "FF-FF-FF-FF-FF-FF"
          end
        end

        context '#state' do
          it 'Can be set and read as attribute' do
            networkinterface.state = "error"
            expect(networkinterface.attributes.occi.networkinterface.state).to eql "error"
          end

          it 'Can be set and read through getter' do
            networkinterface.state = "error"
            expect(networkinterface.state).to eql "error"
          end
        end

        context '#address' do
          it 'Can be set and read as attribute' do
            networkinterface.address = "127.0.0.1"
            expect(networkinterface.attributes.occi.networkinterface.address).to eql "127.0.0.1"
          end

          it 'Can be set and read through getter' do
            networkinterface.address = "127.0.0.1"
            expect(networkinterface.address).to eql "127.0.0.1"
          end
        end

        context '#gateway' do
          it 'Can be set and read as attribute' do
            networkinterface.gateway = "127.0.0.255"
            expect(networkinterface.attributes.occi.networkinterface.gateway).to eql "127.0.0.255"
          end

          it 'Can be set and read through getter' do
            networkinterface.gateway = "127.0.0.255"
            expect(networkinterface.gateway).to eql "127.0.0.255"
          end
        end

        context '#allocation' do
          it 'Can be set and read as attribute' do
            networkinterface.allocation = "static"
            expect(networkinterface.attributes.occi.networkinterface.allocation).to eql "static"
          end

          it 'Can be set and read through getter' do
            networkinterface.allocation = "static"
            expect(networkinterface.allocation).to eql "static"
          end
        end
      end

      context '#ipnetworkinterface' do
        let(:networkinterface){ Occi::Infrastructure::Networkinterface.new }

        it 'adds the Ipnetwork mixin' do
          networkinterface.ipnetworkinterface(true)
          expect(networkinterface.mixins.first.to_s).to eql "http://schemas.ogf.org/occi/infrastructure/networkinterface#ipnetworkinterface"
        end

        it 'removes the Ipnetwork mixin' do
          networkinterface.ipnetworkinterface(true)
          networkinterface.ipnetworkinterface(false)
          expect(networkinterface.mixins.count).to eql 0
        end
      end
    end
  end
end
