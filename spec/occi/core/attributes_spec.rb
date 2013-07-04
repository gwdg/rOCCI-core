require 'rspec'

module Occi
  module Core
    describe Attributes do

      it 'stores properties using hashes in hash notation'  do
        attributes=Occi::Core::Attributes.new
        attributes['test']={}
        attributes['test'].should be_kind_of Occi::Core::Properties
      end

      it 'stores properties using hashes in dot notation'  do
        attributes=Occi::Core::Attributes.new
        attributes.test={}
        attributes.test.should be_kind_of Occi::Core::Properties
      end

      it 'removes attributes' do
        attributes=Occi::Core::Attributes.new
        attributes['one.two']={}
        attributes['one.three']={}
        attr=Occi::Core::Attributes.new
        attr['one.two']={}
        attributes.remove attr
        attributes['one.two'].should be_nil
        attributes['one.three'].should be_kind_of Occi::Core::Properties
      end

      it 'converts properties to an empty attribute' do
        attributes=Occi::Core::Attributes.new
        attributes.test={}
        attr = attributes.convert
        attributes.test.should be_kind_of Occi::Core::Properties
        attr.test.should be_nil
        attr._test.should be_kind_of Occi::Core::Properties
        attributes.convert!
        attributes.test.should be_nil
        attributes._test.should be_kind_of Occi::Core::Properties
      end

    end
  end
end
