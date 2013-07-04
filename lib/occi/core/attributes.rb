module Occi
  module Core
    class Attributes < Hashie::Mash

      attr_accessor :converted

      include Occi::Helpers::Inspect

      def converted?
        @converted||=false
      end

      def [](key)
        if key.to_s.include? '.'
          key, string = key.to_s.split('.', 2)
          attributes = super(key)
          raise "Attribute with key #{key} not found" unless attributes
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
          property_key = '_' + key.to_s
          case value
            when Occi::Core::Attributes
              super(key, value)
            when Occi::Core::Properties
              super(key, value.clone)
              super(property_key, value.clone)
            when Hash
              properties = Occi::Core::Properties.new(value)
              super(key, properties.clone)
              super(property_key, properties.clone)
            when Occi::Core::Entity
              raise "value #{value} derived from Occi::Core::Entity assigned but attribute of type #{self[property_key].type} required" unless self[property_key].type == 'string' if self[property_key]
              raise "value #{value} does not match pattern" unless value.to_s.match '^' + self[property_key].pattern + '$' if Occi::Settings.verify_attribute_pattern if self[property_key]
              super(key, value)
            when String
              raise "value #{value} of type String assigned but attribute of type #{self[property_key].type} required" unless self[property_key].type == 'string' if self[property_key]
              raise "value #{value} does not match pattern" unless value.match '^' + self[property_key].pattern + '$' if Occi::Settings.verify_attribute_pattern if self[property_key]
              super(key, value)
            when Numeric
              raise "value #{value} of type String assigned but attribute of type #{self[property_key].type} required" unless self[property_key].type == 'number' if self[property_key]
              raise "value #{value} does not match pattern" unless value.to_s.match '^' + self[property_key].pattern + '$' if Occi::Settings.verify_attribute_pattern if self[property_key]
              super(key, value)
            when NilClass
              super(key, value)
            else
              raise "value #{value} of type #{value.class} not supported as attribute"
          end
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

      # @return [Array] key value pair of full attribute names with their corresponding values
      def names
        hash = {}
        self.each_key do |key|
          next if self.key?(key[1..-1])
          if self[key].kind_of? Occi::Core::Attributes
            self[key].names.each_pair { |k, v| hash[key + '.' + k] = v unless v.blank? }
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
          if [:Type, :Required, :Mutable, :Default, :Description, :Pattern, :type, :required, :mutable, :default, :description, :pattern].any? { |k| value.key?(k) and not value[k].kind_of? Hash }
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
          if rest.empty?
            attribute[key] = value
          else
            attribute.merge! Attributes.new(key => self.split(rest => value))
          end
        end
        return attribute
      end

      def to_json(*a)
        as_json(*a).to_json(*a)
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        hash = {}
        self.each_pair do |key, value|
          next if self.key?(key[1..-1])
          case value
            when Occi::Core::Attributes
              hash[key] = value.as_json unless value.as_json.size == 0
            else
              hash[key] = value.as_json if value
          end
        end
        hash
      end

    end

  end
end