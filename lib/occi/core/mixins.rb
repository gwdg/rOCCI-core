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
        @entity.attributes.remove mixin.attributes if @entity
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
          mixin = Occi::Core::Mixin.new *mixin.split('#')
        end
        mixin
      end

    end
  end
end
