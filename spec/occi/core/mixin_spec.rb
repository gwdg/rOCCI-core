module Occi
  module Core
    describe Mixin do

      describe '#location' do
        let(:mixin) { Occi::Core::Mixin.new }

        it 'defaults to /mixin/term/' do
          expect(mixin.location).to eq '/mixin/mixin/'
        end

        it 'gets normalized to a relative path' do
          mixin.location = 'http://example.org/mixin/'
          expect(mixin.location).to eq '/mixin/'
        end

        it 'can be set to nil' do
          mixin.location = nil
          expect(mixin.location).to be_nil
        end

        it 'raises an error when location does not start and end with a slash' do
          expect { mixin.location = '/no_slash' }.to raise_error
          expect { mixin.location = 'no_slash/' }.to raise_error
        end

        it 'raises an error when location contains spaces' do
          expect { mixin.location = '/sla shes/' }.to raise_error
        end

        it 'can be set to an empty string' do
          expect { mixin.location = '' }.not_to raise_error
        end
      end

    end
  end
end
