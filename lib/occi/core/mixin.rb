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
        location.blank? ? @location = "/mixins/#{term}/" : @location = location
        @applies = Occi::Core::Kinds.new applies
      end

      # Check if this Mixin instance is related to another Mixin instance.
      #
      # @param kind [Occi::Core::Mixin, String] Mixin or Type Identifier of a Mixin where relation should be checked.
      # @return [true,false]
      def related_to?(mixin)
        self.depends.any? { |dependency| dependency.to_s == mixin.to_s } or self.to_s == mixin.to_s
      end

      def location
        @location.clone
      end

      def related
        self.depends + self.applies
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        mixin = Hashie::Mash.new
        mixin.dependencies = self.depends.join(' ').split(' ') if self.depends.any?
        mixin.applies = self.applies.join(' ').split(' ') if self.applies.any?
        mixin.related = self.related.join(' ').split(' ') if self.related.any?
        mixin.actions = self.actions if self.actions.any?
        mixin.location = self.location if self.location
        mixin.merge! super
        mixin
      end

      # @return [String] text representation
      def to_string
        string = super
        string << ";rel=#{self.related.join(' ').inspect}" if self.related.any?
        string << ";location=#{self.location.inspect}"
        string << self.attributes.to_string_short
        string << ";actions=#{self.actions.join(' ').inspect}" if self.actions.any?
        string
      end

    end
  end
end
