module Occi
  module Infrastructure
    describe Compute do
      let(:compute){ Occi::Infrastructure::Compute.new }
      let(:modl){
        modl = Occi::Model.new
        modl.register_infrastructure
        modl }

      context '#storagelink' do
        let(:target){
          target = Occi::Infrastructure::Storage.new
          # create a random ID as the storage resource must already exist and therefore must have an ID assigned
          target.id = UUIDTools::UUID.random_create.to_s 
          target }
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
          target }
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
#          compute.model=modl
#          compute.architecture = 'z80'
#          expect{compute.check}.to raise_error
#        end
      end

      context '#cores' do
        it 'can be set and read' do
          compute.cores = 32
          expect(compute.cores).to eq 32
        end
        it 'rejects non-numeric values' do
          expect{compute.memory = 'a few'}.to raise_error
        end
        it 'rejects non-matching values' #do
#          compute.model=modl
#          compute.cores = -32
#          expect{compute.check}.to raise_error
#        end
      end

      context '#hostname' do
        it 'can be set and read' do
          compute.hostname = 'testhostname'
          expect(compute.hostname).to eq 'testhostname'
        end
        it 'rejects non-matching values' #do
#          compute.model=modl
#          compute.hostname = 'testhostname'
#          expect{compute.check}.to raise_error
#        end
      end

      context '#speed' do
        it 'can be set and read' do
          compute.speed = 3000.0
          expect(compute.speed).to eq 3000.0
        end
        it 'rejects non-numeric values' do
          expect{compute.memory = 'fast'}.to raise_error
        end
        it 'rejects non-matching values' #do
#          compute.model=modl
#          compute.memory = -4096
#          expect{compute.check}.to raise_error
#        end
      end

      context '#memory' do
        it 'can be set and read' do
          compute.memory = 4096
          expect(compute.memory).to eq 4096
        end
        it 'rejects non-numeric values' do
          expect{compute.memory = 'a lot'}.to raise_error
        end
        it 'rejects non-matching values' #do
#          compute.model=modl
#          compute.memory = -4096
#          expect{compute.check}.to raise_error
#        end
      end

      context '#state' do
        it 'has correct default value' #do
#          compute.model=modl
#          compute.check
#          expect(compute.state).to eq 'inactive'
#        end
        it 'can be set and read' do
          compute.state = 'active'
          expect(compute.state).to eq 'active'
        end
        it 'rejects non-matching values' do
          compute.model=modl
          compute.state = 1
          expect{compute.check}.to raise_error Occi::Errors::AttributeTypeError
        end
      end

      context '#storagelinks'

      context '#networkinterfaces'


    end
  end
end
