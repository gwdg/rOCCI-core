module Occi
  module Core
    class ActionInstance

      include Occi::Helpers::Inspect
      include Occi::Helpers::Comparators::ActionInstance

      attr_accessor :action, :attributes, :model

      class_attribute :action, :attributes

      self.attributes = Occi::Core::Attributes.new

      self.action = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/core#',
                                           term='action_instance',
                                           title='action',
                                           attributes=Occi::Core::Attributes.new(self.attributes)

      def initialize(action = self.action, attributes=self.attributes)
        raise ArgumentError, 'action cannot be nil' unless action
        raise ArgumentError, 'attributes cannot be nil' unless attributes

        if action.kind_of? String
          scheme, term = action.split '#'
          action = Occi::Core::Action.new(scheme, term)
        end
        @action = action

        if attributes.kind_of? Occi::Core::Attributes
          @attributes = attributes.convert
        else
          @attributes = Occi::Core::Attributes.new(attributes)
        end
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        action = Hashie::Mash.new
        action.action = @action.to_s if @action
        action.attributes = @attributes.any? ? @attributes.as_json : Occi::Core::Attributes.new.as_json
        action
      end

      # @return [String] text representation
      def to_text
        text = "Category: #{@action.to_string_short}"
        @attributes.names.each_pair do |name, value|
          value = value.to_s.inspect unless value && value.is_a?(Numeric)
          text << "\nX-OCCI-Attribute: #{name}=#{value}"
        end

        text
      end

      # @return [String] JSON representation
      def to_json
        as_json.to_json
      end

      # @return [Hash] hash containing the HTTP headers of the text/occi rendering
      def to_header
        header = Hashie::Mash.new
        header['Category'] = @action.to_string_short

        attributes = []
        @attributes.names.each_pair do |name, value|
          value = value.to_s.inspect unless value && value.is_a?(Numeric)
          attributes << "#{name}=#{value}"
        end
        header['X-OCCI-Attribute'] = attributes.join(',') if attributes.any?

        header
      end

      # @return [Bool] Indicating whether this action instance is "empty", i.e. required attributes are blank
      def empty?
        action.nil? || action.empty?
      end

      # @return [Bool] Result of the validation process
      def check
        # TODO: impl check for ActionInstance attributes
        true
      end

    end
  end
end
