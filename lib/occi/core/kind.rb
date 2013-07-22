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
        @parent = parent
        @actions = Occi::Core::Actions.new(actions)
        @entities = Occi::Core::Entities.new
        location.blank? ? @location = '/' + term + '/' : @location = location
      end

      def entity_type
        self.class.get_class @scheme, @term, @related
      end

      def location
        @location.clone
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        kind = Hashie::Mash.new
        kind.parent = @parent.to_s
        kind.related = [@parent.to_s]
        kind.actions = @actions.join(' ').split(' ') if @actions.any?
        kind.location = @location if @location
        kind.merge! super
        kind
      end

      # @return [String] string representation of the kind
      def to_string
        string = super
        string << ';rel=' + @parent.to_s.inspect
        string << ';location=' + self.location.inspect
        string << ';attributes=' + @attributes.names.keys.join(' ').inspect if @attributes.any?
        string << ';actions=' + @actions.join(' ').inspect if @actions.any?
        string
      end

    end
  end
end
