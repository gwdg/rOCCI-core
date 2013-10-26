module Occi
  module Core
    describe Attributes do

      context '#[]=' do
        it 'stores properties using hashes in hash notation'  do
          attributes=Occi::Core::Attributes.new
          attributes['test']={}
          
          expect(attributes['test']).to be_kind_of Occi::Core::Properties
        end

        it 'stores properties using hashes in dot notation'  do
          attributes=Occi::Core::Attributes.new
          attributes.test={}

          expect(attributes.test).to be_kind_of Occi::Core::Properties
        end
      end

      context '#remove' do
        it 'removes attributes' do
          attributes=Occi::Core::Attributes.new
          attributes['one.two']={}
          attributes['one.three']={}

          attr=Occi::Core::Attributes.new
          attr['one.two']={}
          attributes.remove attr

          expect(attributes['one.two']).to be_nil
          expect(attributes['one.three']).to be_kind_of Occi::Core::Properties
        end
      end

      context '#convert' do
        it 'converts properties to an empty attribute' do
          attributes=Occi::Core::Attributes.new
          attributes.test={}

          attr = attributes.convert
          expect(attributes.test).to be_kind_of Occi::Core::Properties

          expect(attr.test).to be_nil
          expect(attr._test).to be_kind_of Occi::Core::Properties

          attributes.convert!
          expect(attributes.test).to be_nil
          expect(attributes._test).to be_kind_of Occi::Core::Properties
        end
      end

      context '#==' do

        it 'matches the same instance'
        it 'matches a clone'
        it 'matches a new instance with the same content'
        it 'does not match nil'
        it 'does not match an instance with different content'

      end

      context '#eql?' do

        it 'matches the same instance'
        it 'matches a clone'
        it 'matches a new instance with the same content'
        it 'does not match nil'
        it 'does not match an instance with different content'

      end

      context '#equal?' do

        it 'matches the same instance'
        it 'does not match a clone'

      end

      context '#hash' do

        it 'matches for the same instance'
        it 'matches for a clone'
        it 'matches for a new instance with the same content'
        it 'does not match for an instance with different content'

      end

    end
  end
end
