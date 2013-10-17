module Occi
  module Infrastructure
    describe Compute do
      let(:compute){ Occi::Infrastructure::Compute.new }

      context '#storagelink' do
        let(:target){
          target = Occi::Infrastructure::Storage.new
          # create a random ID as the storage resource must already exist and therefore must have an ID assigned
          target.id = UUIDTools::UUID.random_create.to_s }
        it "creates a single storagelink" do
          compute.storagelink target
          expect(compute.links).to have(1).link
        end
        it "creates a storagelink to a storage resource" do
          compute.storagelink target
          expect(compute.links.first).to be_kind_of Occi::Infrastructure::Storagelink
        end
        it "has the correct link as target" do
          compute.storagelink target
          expect(compute.links.first.target).to be target
        end
      end

      context '#networkinterface' do
        let(:target){
          target = Occi::Infrastructure::Network.new
          # create a random ID as the network resource must already exist and therefore must have an ID assigned
          target.id = UUIDTools::UUID.random_create.to_s
        }
        it "creates a single networkinterface" do
          compute.networkinterface target
          expect(compute.links).to have(1).link
        end
        it "creates a networkinterface to a storage resource" do
          compute.networkinterface target
          expect(compute.links.first).to be_kind_of Occi::Infrastructure::Networkinterface
        end
        it "has the correct interface as target" do
          compute.networkinterface target
          expect(compute.links.first.target).to be target
        end
      end


      context '#architecture' do
        it 'can be set and read' do
          compute.architecture = 'x64'
          expect(compute.architecture).to eq 'x64'
        end
        it 'rejects non-matching values' #do
#          compute.architecture = 'z80'
#          expect(compute.check).to eq false
#        end
      end

      context '#cores' do
        it 'can be set and read' do
          compute.cores = 32
          expect(compute.cores).to eq 32
        end
        it 'rejects non-matching values' #do
#          compute.cores = -32
#          expect(compute.check).to eq false
#        end
      end

      context '#hostname' do
        it 'can be set and read' do
          compute.hostname = 'testhostname'
          expect(compute.hostname).to eq 'testhostname'
        end
        it 'rejects non-matching values' #do
#          compute.hostname = 'testhostname'
#          expect(compute.check).to eq false
#        end
      end

      context '#speed'

      context '#memory' do
        it 'can be set and read' do
          compute.memory = 4096
          expect(compute.memory).to eq 4096
        end
        it 'rejects non-matching values' #do
#          compute.memory = -4096
#          expect(compute.check).to eq false
#        end
      end

      context '#state' do
        it 'has correct default value' #do
#          expect(compute.state).to eq 'inactive'
#        end
        it 'can be set and read' do
          compute.state = 'active'
          expect(compute.state).to eq 'active'
        end
        it 'rejects non-matching values' #do
#          compute.state = 'broken'
#          expect(compute.check).to eq false
#        end
      end

      context '#storagelinks'

      context '#networkinterfaces'


    end
  end
end
