module Occi
  module Infrastructure
    describe Storagelink do

      context 'setters/getters' do
        let(:storagelink){ Occi::Infrastructure::Storagelink.new }
        context '#deviceid' do
          it 'Can be set and read as attribute' do
            storagelink.deviceid = "sda"
            expect(storagelink.attributes.occi.storagelink.deviceid).to eql "sda"
          end

          it 'Can be set and read through getter' do
            storagelink.deviceid = "sda"
            expect(storagelink.deviceid).to eql "sda"
          end
        end

        context '#mountpoint' do
          it 'Can be set and read as attribute' do
            storagelink.mountpoint = "/mnt/sda"
            expect(storagelink.attributes.occi.storagelink.mountpoint).to eql "/mnt/sda"
          end

          it 'Can be set and read through getter' do
            storagelink.mountpoint = "/mnt/sda"
            expect(storagelink.mountpoint).to eql "/mnt/sda"
          end
        end

        context '#state' do
          it 'Can be set and read as attribute' do
            storagelink.state = "active"
            expect(storagelink.attributes.occi.storagelink.state).to eql "active"
          end

          it 'Can be set and read through getter' do
            storagelink.state = "active"
            expect(storagelink.state).to eql "active"
          end
        end
      end
    end
  end
end
