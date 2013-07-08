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

      # TODO: fix mixin conversion
      def convert(mixin)
        mixin = super mixin

        if mixin.kind_of? String
          scheme, term = mixin.split '#'
          scheme += '#'

          mixin = Occi::Core::Category.get_class scheme, term, [Occi::Core::Mixin.new]
          if mixin.respond_to? :new
            mixin = mixin.new(scheme, term)
          end
        end
        mixin
      end

    end
  end
end