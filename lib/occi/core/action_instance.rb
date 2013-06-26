module Occi
  module Core
    class ActionInstance

      include Occi::Helpers::Inspect

      attr_accessor :action, :attributes, :model

      class_attribute :action, :attributes

      self.attributes = Occi::Core::Attributes.new

      self.action = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core#',
                                           term='action_instance',
                                           title='action',
                                           attributes=self.attributes

      def initialize(action = self.action, attributes=self.attributes)
        if action.kind_of? String
          scheme, term = action.split '#'
          action = Occi::Core::Action.new(scheme, term)
        end
        @action = action
        @attributes = Occi::Core::Attributes.new attributes
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        action = Hashie::Mash.new
        action.action = @action.to_s if @action
        action.attributes = @attributes if @attributes.any?
        action
      end

    end
  end
end