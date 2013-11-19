module Occi
  module Core
    describe Mixins do

      context '#entity=' do
        let(:ent){ Occi::Core::Entity.new }
        let(:mixins){ Occi::Core::Mixins.new }

        context 'assignment with mixins set empty' do
          let(:mixin){ Occi::Core::Mixin.new }
          it 'assigns entity to an empty mixin' do
            mixins.entity = ent
            expect(mixins.entity).to eql ent
          end
        end

        context 'converting attributes form members into the assigned entity' do
          let(:mixin){ mixin = Occi::Core::Mixin.new 
            mixin.attributes['stringtype'] = { :type => 'string',
                                               :pattern => '[adefltuv]+',
                                               :default => 'defaultvalue',
                                               :mutable => true }
            mixin.attributes['stringtype'] = 'flute' 
            mixin }

          before(:each) {
            mixins << mixin
            mixins.entity = ent }

          it 'removes assigned values' do
            expect(mixins.entity.attributes['stringtype']).to eql nil
          end

          it 'preserves attribute properties' do
            expect(mixins.entity.attributes['_stringtype']).to_not eql nil
          end
        end
      end

      context '<<' do
        let!(:mixins){ Occi::Core::Mixins.new }

        it 'adds a mixin to an empty set' do
          mixins << Occi::Infrastructure::OsTpl.mixin
          expect(mixins.include?(Occi::Infrastructure::OsTpl.mixin)).to eql true
        end

        it 'adds a mixin to an empty set' do
          mixins << Occi::Infrastructure::OsTpl.mixin
          mixins << Occi::Infrastructure::ResourceTpl.mixin
          expect(mixins.include?(Occi::Infrastructure::ResourceTpl.mixin)).to eql true
        end

        it 'only adds the supplied mixin' do
          mixins << Occi::Infrastructure::OsTpl.mixin
          expect(mixins.include?(Occi::Infrastructure::ResourceTpl.mixin)).to eql false
        end

        it 'adds mixin from string' do
          mixins << "http://schemas.ogf.org/occi/core#testmixin"
          expect(mixins.first.term).to eql "testmixin"
        end
      end

      context '#remove' do
        let!(:mixins){ Occi::Core::Mixins.new }

        it 'removes last mixin from the set' do
          mixins << Occi::Infrastructure::OsTpl.mixin
          mixins.remove(Occi::Infrastructure::OsTpl.mixin)
          expect(mixins.include?(Occi::Infrastructure::OsTpl.mixin)).to eql false
        end

        it 'removes mixin from among multiple members' do
          mixins << Occi::Infrastructure::OsTpl.mixin
          mixins << Occi::Infrastructure::ResourceTpl.mixin
          mixins.remove(Occi::Infrastructure::OsTpl.mixin)
          expect(mixins.include?(Occi::Infrastructure::OsTpl.mixin)).to eql false
        end

        it 'leaves other unaffected' do
          mixins << Occi::Infrastructure::OsTpl.mixin
          mixins << Occi::Infrastructure::ResourceTpl.mixin
          mixins.remove(Occi::Infrastructure::OsTpl.mixin)
          expect(mixins.include?(Occi::Infrastructure::ResourceTpl.mixin)).to eql true
        end

        it 'removes attributes from the entity attribute' do
          ent = Occi::Core::Entity.new
          mixin = Occi::Core::Mixin.new
          mixin.attributes['stringtype'] = { :type => 'string', :pattern => '[adefltuv]+', :default => 'defaultvalue', :mutable => true }
          mixin.attributes['stringtype'] = 'flute'

          mixins << mixin
          mixins.entity = ent

          mixins.remove(mixin)

          expect(mixins.entity.attributes['_stringtype']).to eql nil
        end
      end

      context '#convert' do
      end
    end
  end
end
