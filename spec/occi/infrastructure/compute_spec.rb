module Occi
  module Infrastructure
    describe Compute do
      let(:compute){ Occi::Infrastructure::Compute.new }
      let(:modl){
        modl = Occi::Model.new
        modl.register_infrastructure
        modl }

      context 'Storage Links' do
        let(:target){
          target = Occi::Infrastructure::Storage.new
          # create a random ID as the storage resource must already exist and therefore must have an ID assigned
          target.id = UUIDTools::UUID.random_create.to_s 
          target }

        context '#storagelink' do
          it "creates a single storagelink" do
            compute.storagelink target
            expect(compute.links.count).to eq 1
          end

          it "creates a storagelink to a storage resource" do
            compute.storagelink target
            expect(compute.links.first).to be_kind_of Occi::Infrastructure::Storagelink
          end

          it "has the correct link as target" do
            compute.storagelink target
            expect(compute.links.first.target).to eq target.to_s
          end

          it "has target with correct ID" do
            compute.storagelink target
            expect(compute.links.first.target.split('/').last).to eq target.id
          end
        end

        context '#storagelinks' do
          it 'has the correct number of members -- single' do
            compute.storagelink target
            compute.model=modl
            expect(compute.storagelinks.count).to eq 1
          end

          it 'has the correct number of members -- double' do
            target2 = Occi::Infrastructure::Storage.new
            target2.id = UUIDTools::UUID.random_create.to_s 
            compute.storagelink target
            compute.storagelink target2
            compute.model=modl
            expect(compute.storagelinks.count).to eq 2
          end

          it 'shows correctly in collections' do
            compute.storagelink target
            compute.model=modl
            expect(compute.storagelinks[0].target.split('/').last).to eq target.id
          end
        end
      end

      context 'Network Interfaces' do
        let(:target){
          target = Occi::Infrastructure::Network.new
          # create a random ID as the network resource must already exist and therefore must have an ID assigned
          target.id = UUIDTools::UUID.random_create.to_s
          target }

        context '#networkinterface' do
          it "creates a single networkinterface" do
            compute.networkinterface target
            expect(compute.links.count).to eq 1
          end

          it "creates a networkinterface to a storage resource" do
            compute.networkinterface target
            expect(compute.links.first).to be_kind_of Occi::Infrastructure::Networkinterface
          end

          it "has the correct interface as target" do
            compute.networkinterface target
            expect(compute.links.first.target).to eq target.to_s
          end
        end

        context '#networkinterfaces' do
          it 'has the correct number of members -- single' do
            compute.networkinterface target
            compute.model=modl
            expect(compute.networkinterfaces.count).to eq 1
          end

          it 'has the correct number of members -- double' do
            target2 = Occi::Infrastructure::Network.new
            target2.id = UUIDTools::UUID.random_create.to_s
            compute.networkinterface target
            compute.networkinterface target2
            compute.model=modl
            expect(compute.networkinterfaces.count).to eq 2
          end

          it 'shows correctly in collections' do
            compute.networkinterface target
            compute.model=modl
            expect(compute.networkinterfaces[0].target.split('/').last).to eq target.id
          end
        end
      end

      context '#architecture' do
        it 'can be set and read' do
          compute.architecture = 'x64'
          expect(compute.architecture).to eq 'x64'
        end

        context 'Pattern matching' do
          before(:each) { Occi::Settings['compatibility']=false }
          after(:each) { Occi::Settings.reload! }

          it 'preserves non-matching values with verification settings off' do
            Occi::Settings['verify_attribute_pattern']=false
            compute.model=modl
            expect{compute.architecture = 'z80'}.to_not raise_error
          end

          it 'rejects non-matching values with verification settings on' do
            Occi::Settings['verify_attribute_pattern']=true
            compute.model=modl
            expect{compute.architecture = 'z80'}.to raise_error Occi::Errors::AttributeTypeError
          end
        end
      end

      context '#cores' do
        it 'can be set and read' do
          compute.cores = 32
          expect(compute.cores).to eq 32
        end

        it 'rejects non-numeric values' do
          expect{compute.memory = 'a few'}.to raise_error
        end
      end

      context '#hostname' do
        it 'can be set and read' do
          compute.hostname = 'testhostname'
          expect(compute.hostname).to eq 'testhostname'
        end

        context 'Pattern matching' do
          before(:each) { Occi::Settings['compatibility']=false }
          after(:each) { Occi::Settings.reload! }

          it 'preserves non-matching values with verification settings off' do
            Occi::Settings['verify_attribute_pattern']=false
            compute.model=modl
            expect{compute.hostname = 'notaproperhostname'}.to_not raise_error
          end

          it 'rejects non-matching values with verification settings on' do
            Occi::Settings['verify_attribute_pattern']=true
            compute.model=modl
            expect{compute.hostname = 'notaproperhostname'}.to raise_error Occi::Errors::AttributeTypeError
          end
        end
      end

      context '#speed' do
        it 'can be set and read' do
          compute.speed = 3000.0
          expect(compute.speed).to eq 3000.0
        end

        it 'rejects non-numeric values' do
          expect{compute.memory = 'fast'}.to raise_error
        end
      end

      context '#memory' do
        it 'can be set and read' do
          compute.memory = 4096
          expect(compute.memory).to eq 4096
        end

        it 'rejects non-numeric values' do
          expect{compute.memory = 'a lot'}.to raise_error
        end
      end

      context '#state' do
        it 'has correct default value with set_defaults == true' do
          compute.model=modl
          compute.check(true)
          expect(compute.state).to eq 'inactive'
        end

        it 'does not take the default value with set_defaults set to default' do
          compute.model=modl
          compute.check
          expect(compute.state).to_not eq 'inactive'
        end

        it 'can be set and read' do
          compute.state = 'active'
          expect(compute.state).to eq 'active'
        end

        context 'Pattern matching' do
          before(:each) { Occi::Settings['compatibility']=false }
          after(:each) { Occi::Settings.reload! }

          it 'preserves non-matching values with verification settings off' do
            Occi::Settings['verify_attribute_pattern']=false
            compute.model=modl
            expect{compute.state = 'broken'}.to_not raise_error
          end

          it 'rejects non-matching values with verification settings on' do
            Occi::Settings['verify_attribute_pattern']=true
            compute.model=modl
            expect{compute.state = 'broken'}.to raise_error Occi::Errors::AttributeTypeError
          end
        end
      end
    end
  end
end
