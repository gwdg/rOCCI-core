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

      context '#remove' do
      end

      context '<<' do
      end

      context '#convert' do
      end
    end
  end
end
