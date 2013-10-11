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
        @attributes = attributes.convert
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        action = Hashie::Mash.new
        action.action = @action.to_s if @action
        action.attributes = @attributes if @attributes.any?
        action
      end

      # @return [String] text representation
      def to_text
        text = "Category: #{@action.to_string_short}"
        @attributes.names.each_pair do |name, value|
          value = value.inspect
          text << "\nX-OCCI-Attribute: #{name}=#{value}"
        end

        text
      end

      # @return [Hash] hash containing the HTTP headers of the text/occi rendering
      def to_header
        header = Hashie::Mash.new
        header['Category'] = @action.to_string_short

        attributes = []
        @attributes.names.each_pair do |name, value|
          attributes << "#{name}=#{value.to_s.inspect}"
        end
        header['X-OCCI-Attribute'] = attributes.join(',') if attributes.any?

        header
      end

    end
  end
end