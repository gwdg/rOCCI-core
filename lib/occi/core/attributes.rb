module Occi
  module Core
    class Attributes < Hashie::Mash

      attr_accessor :converted

      include Occi::Helpers::Inspect
      include Occi::Helpers::Comparators::Attributes

      PROPERTY_KEYS = [:Type, :Required, :Mutable, :Default, :Description, :Pattern, :type, :required, :mutable, :default, :description, :pattern]

      def initialize(source_hash = nil, default = nil, &blk)
        # All internal Hashie::Mash elements in source_hash have to be re-typed
        # to Occi::Core::Attributes, so we have to rebuild the object from scratch
        source_hash = source_hash.to_hash if source_hash.kind_of? Hashie::Mash
        super(source_hash, default, &blk)
      end

      def converted?
        @converted||=false
      end

      def [](key)
        if key.to_s.include? '.'
          key, string = key.to_s.split('.', 2)
          attributes = super(key)
          raise Occi::Errors::AttributeMissingError, "Attribute with key #{key} not found" unless attributes
          attributes[string]
        else
          super(key)
        end
      end

      def []=(key, value)
        if key.to_s.include? '.'
          key, string = key.to_s.split('.', 2)
          super(key, Occi::Core::Attributes.new) unless self[key].kind_of? Occi::Core::Attributes
          self[key][string] = value
        else
          property_key = "_#{key.to_s}"
          validate_and_assign(key, value, property_key)
        end
      end

      def remove(attributes)
        attributes.keys.each do |key|
          if self.keys.include? key
            case self[key]
              when Occi::Core::Attributes
                self[key].remove attributes[key]
              else
                self.delete(key)
            end
          end
        end
        self
      end

      def convert(attributes=Occi::Core::Attributes.new(self))
        attributes.each_pair do |key, value|
          next if attributes.key?(key[1..-1])
          case value
            when Occi::Core::Attributes
              value.convert!
            else
              attributes[key] = nil
          end
        end
        attributes.converted = true
        attributes
      end

      def convert!
        convert self
      end

      # @return [Hash] key value pair of full attribute names with their corresponding values
      def names
        hash = {}
        self.each_key do |key|
          next if self.key?(key[1..-1])
          if self[key].kind_of? Occi::Core::Attributes
            self[key].names.each_pair { |k, v| hash["#{key}.#{k}"] = v unless v.blank? }
          else
            hash[key] = self[key]
          end
        end
        hash
      end

      # @param [Hash] attributes
      # @return [Occi::Core::Properties] parsed Properties
      def self.parse(hash)
        hash ||= {}
        attributes = Occi::Core::Attributes.new
        hash.each_pair do |key, value|
          if PROPERTY_KEYS.any? { |k| value.key?(k) and not value[k].kind_of? Hash }
            value[:type] ||= value[:Type] ||= "string"
            value[:required] ||= value[:Required] ||= false
            value[:mutable] ||= value[:Mutable] ||= false
            value[:default] = value[:Default] if value[:Default]
            value[:description] = value[:Description] if value[:Description]
            value[:pattern] ||= value[:Pattern] ||= ".*"
            value.delete :Type
            value.delete :Required
            value.delete :Mutable
            value.delete :Default
            value.delete :Description
            value.delete :Pattern
            attributes[key] = Occi::Core::Properties.new value
          else
            attributes[key] = self.parse attributes[key]
          end
        end

        attributes
      end

      # @param [Hash] attributes key value pair of full attribute names with their corresponding values
      # @return [Occi::Core::Properties]
      def self.split(attributes)
        attribute = Attributes.new
        attributes.each do |name, value|
          key, _, rest = name.partition('.')
          if rest.blank?
            attribute[key] = value
          else
            attribute.merge! Attributes.new(key => self.split(rest => value))
          end
        end

        attribute
      end

      # @return [String]
      def to_string
        attributes = ';'
        attributes << to_header.gsub(',', ';')

        attributes == ';' ? '' : attributes
      end

      # @return [String]
      def to_string_short
        any? ? ";attributes=#{names.keys.join(' ').inspect}" : ""
      end

      # @return [String]
      def to_text
        text = ""
        names.each_pair do |name, value|
          # TODO: find a better way to skip properties
          next if name.include? '._'
          text << "\nX-OCCI-Attribute: #{name}=#{value.inspect}"
        end

        text
      end

      # @return [String] of attributes put in an array and then concatenated into a string
      def to_header
        attributes = []
        names.each_pair do |name, value|
          # TODO: find a better way to skip properties
          next if name.include? '._'
          attributes << "#{name}=#{value.to_s.inspect}"
        end

        attributes.join(',')
      end

      def to_json(*a)
        as_json(*a).to_json(*a)
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        hash = Hashie::Mash.new
        self.each_pair do |key, value|
          next if self.key?(key[1..-1])
          # TODO: find a better way to skip properties
          next if key.start_with? '_'

          case value
            when Occi::Core::Attributes
              hash[key] = value.as_json if value && value.as_json.size > 0
            when Occi::Core::Entity
              hash[key] = value.to_s unless value.blank?
            when Occi::Core::Category
              hash[key] = value.to_s
            else
              hash[key] = value.as_json if value
          end
        end

        hash
      end

      private

      def validate_and_assign(key, value, property_key)
        case value
        when Occi::Core::Attributes
          add_to_hashie(key, value)
        when Occi::Core::Properties
          add_to_hashie(key, value.clone)
          add_to_hashie(property_key, value.clone)
        when Hash
          properties = Occi::Core::Properties.new(value)
          add_to_hashie(key, properties.clone)
          add_to_hashie(property_key, properties.clone)
        when Occi::Core::Entity
          match_type(value, self[property_key], 'string') if self[property_key]
          add_to_hashie(key, value)
        when String
          match_type(value, self[property_key], 'string') if self[property_key]
          add_to_hashie(key, value)
        when Numeric
          match_type(value, self[property_key], 'number') if self[property_key]
          add_to_hashie(key, value)
        when FalseClass, TrueClass
          match_type(value, self[property_key], 'boolean') if self[property_key]
          add_to_hashie(key, value)
        when NilClass
          add_to_hashie(key, value)
        else
          raise Occi::Errors::AttributeTypeError, "value #{value} of type #{value.class} not supported as attribute"
        end
      end

      def add_to_hashie(*args)
        Hashie::Mash.instance_method(:[]=).bind(self).call(*args)
      end

      def match_type(value, property, expected_type)
        raise Occi::Errors::AttributeTypeError, "value #{value} derived from #{value.class} assigned but attribute of type #{property.type} required" unless property.type == expected_type
        match_pattern(property.pattern, value)
      end

      def match_pattern(pattern, value)
        return if pattern.blank?

        if Occi::Settings.verify_attribute_pattern && !Occi::Settings.compatibility
          raise Occi::Errors::AttributeTypeError, "value #{value.to_s} does not match pattern #{pattern}" unless value.to_s.match "^#{pattern}$"
        else
          Occi::Log.warn "[#{self.class}] Skipping pattern checks on attributes, turn off the compatibility mode and enable the attribute pattern check in settings!"
        end
      end

    end

  end
end
