module Occi
  module Core
    class Kind < Occi::Core::Category

      attr_accessor :entities, :parent, :actions, :location

      # @param [String ] scheme
      # @param [String] term
      # @param [String] title
      # @param [Hash] attributes
      # @param [Array] related
      # @param [Array] actions
      def initialize(scheme='http://schemas.ogf.org/occi/core#',
          term='kind',
          title=nil,
          attributes=Occi::Core::Attributes.new,
          parent=nil,
          actions=Occi::Core::Actions.new,
          location=nil)
        super(scheme, term, title, attributes)
        @parent = [parent].flatten.first
        @actions = Occi::Core::Actions.new(actions)
        @entities = Occi::Core::Entities.new
        location.blank? ? @location = '/' + term + '/' : @location = location
      end

      def entity_type
        self.class.get_class self.scheme, self.term, self.parent
      end

      def location
        @location.clone
      end

      def related
        [self.parent]
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        kind = Hashie::Mash.new
        kind.parent = self.parent.to_s if self.parent
        kind.related = self.related.join(' ').split(' ') if self.related.any?
        kind.actions = self.actions.join(' ').split(' ') if self.actions.any?
        kind.location = self.location if self.location
        kind.merge! super
        kind
      end

      # @return [String] string representation of the kind
      def to_string
        string = super
        string << ';rel=' + self.related.first.to_s.inspect if self.related.any?
        string << ';location=' + self.location.inspect
        string << ';attributes=' + self.attributes.names.keys.join(' ').inspect if self.attributes.any?
        string << ';actions=' + self.actions.join(' ').inspect if self.actions.any?
        string
      end

    end
  end
end
