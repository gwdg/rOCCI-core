module Occi
  module Core
    describe Category do

      describe '.new' do

        it 'instantiates a new Category' do
          category = Category.new
          category.scheme.should == 'http://schemas.ogf.org/occi/core#'
          category.term.should == 'category'
          category.title.should be_nil
          category.attributes.should be_kind_of Occi::Core::Attributes
          category.attributes.should be_empty
        end

        it 'instantiates a new Category and ensures that the scheme ends with a #' do
          category = Category.new *'http://schemas.ogf.org/occi/core#category'.split('#')
          category.scheme.should == 'http://schemas.ogf.org/occi/core#'
          category.term.should == 'category'
          category.title.should be_nil
          category.attributes.should be_kind_of Occi::Core::Attributes
          category.attributes.should be_empty
        end

      end

      describe '#type_identifier' do

        it 'returns the type identifier of the category' do
          category = Category.new
          category.type_identifier.should == 'http://schemas.ogf.org/occi/core#category'
        end

      end

      # rendering

    end
  end
end
