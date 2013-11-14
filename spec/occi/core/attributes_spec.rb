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

      context 'comparators' do
        let(:attrs){
          attrs = Occi::Core::Attributes.new
            attrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
            attrs['stringtype'] = { :type => 'string', :pattern => '[adefltuv]+', :default => 'defaultvalue', :mutable => true }
            attrs['booleantype'] = { :type => 'boolean', :default => true, :mutable => true}
            attrs['booleantypefalse'] = { :type => 'boolean', :default => false, :mutable => true }
            attrs['booleantypepattern'] = { :type => 'boolean', :default => true, :mutable => true, :pattern => true }
          attrs }
        let(:clone){ clone = attrs.clone }
        let(:newattrs){
          newattrs = Occi::Core::Attributes.new
            newattrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
            newattrs['stringtype'] = { :type => 'string', :pattern => '[adefltuv]+', :default => 'defaultvalue', :mutable => true }
            newattrs['booleantype'] = { :type => 'boolean', :default => true, :mutable => true}
            newattrs['booleantypefalse'] = { :type => 'boolean', :default => false, :mutable => true }
            newattrs['booleantypepattern'] = { :type => 'boolean', :default => true, :mutable => true, :pattern => true }
          newattrs }
        let(:diffattrs){
          diffattrs = Occi::Core::Attributes.new
            diffattrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
            diffattrs['stringtype'] = { :type => 'string', :pattern => '[adefltuv]+', :default => 'anothervalue', :mutable => true } # <=
            diffattrs['booleantype'] = { :type => 'boolean', :default => true, :mutable => true}
            diffattrs['booleantypefalse'] = { :type => 'boolean', :default => false, :mutable => true }
            diffattrs['booleantypepattern'] = { :type => 'boolean', :default => true, :mutable => true, :pattern => true }
          diffattrs }

        context '#==' do
          it 'matches the same instance' do
            expect(attrs==attrs).to eql true
          end

          it 'matches a clone' do
            expect(attrs==clone).to eql true
          end
    
          it 'matches a new instance with the same content' do
            expect(attrs==newattrs).to eql true
          end

          it 'does not match nil' do
            expect(attrs==nil).to eql false
          end

          it 'does not match an instance with different content' do
            expect(attrs==diffattrs).to eql false
          end
        end

        context '#eql?' do
          it 'matches the same instance' do
            expect(attrs.eql?(attrs)).to eql true
          end

          it 'matches a clone' do
            expect(attrs.eql?(clone)).to eql true
          end
    
          it 'matches a new instance with the same content' do
            expect(attrs.eql?(newattrs)).to eql true
          end

          it 'does not match nil' do
            expect(attrs.eql?(nil)).to eql false
          end

          it 'does not match an instance with different content' do
            expect(attrs.eql?(diffattrs)).to eql false
          end
        end

        context '#equal?' do
          it 'matches the same instance' do
            expect(attrs.equal?(attrs)).to eql true
          end

          it 'does not match a clone' do
            expect(attrs.equal?(clone)).to eql false
          end
        end

        context '#hash' do
          it 'matches for the same instance' do
            expect(attrs.hash).to eql attrs.hash
          end

          it 'matches for a clone' do
            expect(attrs.hash).to eql clone.hash
          end

          it 'matches for a new instance with the same content' do
            expect(attrs.hash).to eql newattrs.hash
          end

          it 'does not match for an instance with different content' do
            expect(attrs.hash).to_not eql diffattrs.hash
          end
        end
      end
    end
  end
end
