module Occi
  module Core
    class Mixin < Occi::Core::Category

      attr_accessor :entities, :depends, :actions, :location, :applies

      # @param [String ] scheme
      # @param [String] term
      # @param [String] title
      # @param [Occi::Core::Attributes,Hash,NilClass] attributes
      # @param [Occi::Core::Categories,Hash,NilClass] related
      # @param [Occi::Core::Actions,Hash,NilClass] actions
      def initialize(scheme='http://schemas.ogf.org/occi/core#',
          term='mixin',
          title=nil,
          attributes=Occi::Core::Attributes.new,
          depends=Occi::Core::Dependencies.new,
          actions=Occi::Core::Actions.new,
          location='',
          applies=Occi::Core::Kinds.new)

        super(scheme, term, title, attributes)
        @depends = Occi::Core::Dependencies.new depends
        @actions = Occi::Core::Actions.new actions
        @entities = Occi::Core::Entities.new
        location.blank? ? @location = '/mixins/' + term + '/' : @location = location
        @applies = Occi::Core::Kinds.new applies
      end

      def location
        @location.clone
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        mixin = Hashie::Mash.new
        mixin.dependencies = @depends.join(' ').split(' ') if @depends.any?
        mixin.applies = @applies.join(' ').split(' ') if @applies.any?
        mixin.related = @depends.join(' ').split(' ') if @depends.any?
        mixin.related = mixin.related.to_a + @applies.join(' ').split(' ') if @applies.any?
        mixin.actions = @actions if @actions.any?
        mixin.location = @location if @location
        mixin.merge! super
        mixin
      end

      # @return [String] text representation
      def to_string
        string = super
        string << ';rel=' + @related.join(' ').inspect if @related.any?
        string << ';location=' + self.location.inspect
        string << ';attributes=' + @attributes.names.keys.join(' ').inspect if @attributes.any?
        string << ';actions=' + @actions.join(' ').inspect if @actions.any?
        string
      end

    end
  end
end
