module Occi
  module Infrastructure
    describe Storage do

      context 'setters/getters' do
        let(:storage){ Occi::Infrastructure::Storage.new }
        context '#size' do
          it 'Can be set and read as attribute' do
            storage.size = 16777216
            expect(storage.attributes.occi.storage['size']).to eql 16777216
          end

          it 'Can be set and read through getter' do
            storage.size = 16777216
            expect(storage.size).to eql 16777216
          end
        end

        context '#state' do
          it 'Can be set and read as attribute' do
            storage.state = "online"
            expect(storage.attributes.occi.storage.state).to eql "online"
          end

          it 'Can be set and read through getter' do
            storage.state = "online"
            expect(storage.state).to eql "online"
          end
        end
      end
    end
  end
end
