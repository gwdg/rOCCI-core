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
      end

    end
  end
end
