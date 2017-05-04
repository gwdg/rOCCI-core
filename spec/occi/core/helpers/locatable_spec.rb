module Occi
  module Core
    module Helpers
      describe Locatable do
        let(:locatable_object) do
          object = instance_double('RocciCoreSpec::TestObject')
          object.extend(Locatable)
        end
        let(:test_location) { URI.parse('/test/') }

        describe '#location' do
          it 'raises exception when location not set' do
            expect { locatable_object.location }.to raise_error(RuntimeError)
          end

          it 'returns location when set' do
            locatable_object.instance_variable_set(:@location, test_location)
            expect(locatable_object.location).to eq test_location
          end
        end

        describe '#generate_location' do
          it 'raises exception by default' do
            expect { locatable_object.send(:generate_location) }.to raise_error(RuntimeError)
          end
        end
      end
    end
  end
end
