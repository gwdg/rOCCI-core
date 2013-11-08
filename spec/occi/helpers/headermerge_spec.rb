module Occi
  module Helpers
    describe "HeaderMerge" do
      context '.header_merge' do
        it 'merges two mashes correctly' do
          mash1 = Hashie::Mash.new 
          mash1['a'] = 'a'
          mash1['b'] = 'b'
          second = Hashie::Mash.new 
          second['a'] = 'd'
          second['c'] = 'c'

          mash1 = Occi::Helpers::HeaderMerge.header_merge(mash1, second, ',')

          expected = Hashie::Mash.new 
          expected['a'] = 'a,d'
          expected['b'] = 'b'
          expected['c'] = 'c'
          expect(mash1).to eql expected
        end

      end
    end
  end
end

