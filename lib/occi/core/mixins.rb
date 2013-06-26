module Occi
  module Core
    class Mixins < Occi::Core::Categories

      attr_accessor :entity

      def entity=(entity)
        self.each { |mixin| entity.attributes.merge! mixin.attributes.convert }
        @entity = entity
      end

      def remove(mixin)
        mixin = convert mixin
        @entity.attributes.remove mixin.attributes
        self.delete mixin
      end

      def <<(mixin)
        mixin = convert mixin
        @entity.attributes.merge! mixin.attributes.convert if @entity
        super mixin
      end

      private

      def convert(category)
        category = super category

        if category.kind_of? String
          scheme, term = category.split '#'
          scheme += '#'

          klass = Occi::Core::Category.get_class scheme, term, [Occi::Core::Mixin.new]
          category = klass.new(scheme, term)
        end
        category
      end

    end
  end
end