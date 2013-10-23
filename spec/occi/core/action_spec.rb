module Occi
  module Core
    describe Action do
      let(:action){ Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core/entity/action#', term='testaction', title='testaction action' }

      it 'can be instantiated' do
        expect(action).to be_an_instance_of(Occi::Core::Action)
      end

      context '#term' do
        it 'has correct term' do
          expect(action.term).to eql 'testaction'
        end
      end

      context '#title' do
        it 'has correct title' do
          expect(action.title).to eql 'testaction action'
        end
      end

      context '#scheme' do
        it 'has correct scheme' do
          expect(action.scheme).to eql 'http://schemas.ogf.org/occi/core/entity/action#'
        end
      end

      context '#to_text' do
        it 'renders text correctly' do
          action.attributes = Occi::Core::Attributes.new
          action.attributes['numbertype'] =  { :type => 'number',
                                               :default => 42,
                                               :mutable => true }
          action.attributes['stringtype'] =  { :type => 'string',
                                               :pattern => '[adefltuv]+',
                                               :default => 'defaultvalue',
                                               :mutable => true }
          action.attributes['booleantype'] = { :type => 'boolean',
                                               :default => true,
                                               :mutable => true }

          expected = 'Category: testaction;scheme="http://schemas.ogf.org/occi/core/entity/action#";class="action";title="testaction action";attributes="numbertype stringtype booleantype"'

          expect(action.to_text).to eql expected
        end
      end

      context '#to_header' do
        it 'renders text correctly' do
          action.attributes = Occi::Core::Attributes.new
          action.attributes['numbertype'] =  { :type => 'number',
                                               :default => 42,
                                               :mutable => true }
          action.attributes['stringtype'] =  { :type => 'string',
                                               :pattern => '[adefltuv]+',
                                               :default => 'defaultvalue',
                                               :mutable => true }
          action.attributes['booleantype'] = { :type => 'boolean',
                                               :default => true,
                                               :mutable => true }

          expected = {:Category => "testaction;scheme=\"http://schemas.ogf.org/occi/core/entity/action#\";class=\"action\";title=\"testaction action\";attributes=\"numbertype stringtype booleantype\""}
          expect(action.to_header).to eql expected 
        end
      end


    end
  end
end

