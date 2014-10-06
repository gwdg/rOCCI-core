module Occi
  module Core
    class Attributes < Hashie::Mash

      attr_accessor :converted

      include Occi::Helpers::Inspect
      include Occi::Helpers::Comparators::Attributes

      def initialize(source_hash = {}, default = nil, &blk)
        raise ArgumentError, 'Source_hash is a mandatory argument!' unless source_hash
        raise ArgumentError, 'Source_hash must be a hash-like structure!' unless source_hash.kind_of?(Hash)

        # All internal Hashie::Mash elements in source_hash have to be re-typed
        # to Occi::Core::Attributes, so we have to rebuild the object from scratch
        source_hash = source_hash.to_hash unless source_hash.kind_of?(Occi::Core::Attributes)

        super(source_hash, default, &blk)
      end

      def converted?
        @converted||=false
      end

      def [](key)
        if key.to_s.include? '.'
          key, string = key.to_s.split('.', 2)
          attributes = super(key)
          raise Occi::Errors::AttributeMissingError,
                "Attribute with key #{key} not found" unless attributes
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
          next unless self.keys.include?(key)

          case self[key]
          when Occi::Core::Attributes
            self[key].remove attributes[key]
          else
            self.delete(key)
          end
        end

        self
      end

      def convert(attributes=Occi::Core::Attributes.new(self))
        attributes.each_pair do |key, value|
          next if key =~ /^_/
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
          next if key =~ /^_/
          if self[key].kind_of? Occi::Core::Attributes
            self[key].names.each_pair { |k, v| hash["#{key}.#{k}"] = v unless v.nil? }
          else
            hash[key] = self[key]
          end
        end

        hash
      end

      # @param [Hash] attributes
      # @return [Occi::Core::Attributes] parsed attributes with properties
      def self.parse_properties(hash)
        hash ||= {}
        raise Occi::Errors::ParserInputError,
              'Hash must be a hash-like structure!' unless hash.respond_to?(:each_pair)

        attributes = Occi::Core::Attributes.new
        hash.each_pair do |key, value|
          if Occi::Core::Properties.contains_props?(value)
            value = value.to_hash if value.kind_of?(Hashie::Mash)
            attributes[key] = Occi::Core::Properties.new(value)
          else
            attributes[key] = self.parse_properties(value)
          end
        end

        attributes
      end

      # @param [Hash] attributes key value pair of full attribute names with their corresponding values
      # @return [Occi::Core::Attributes]
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
        attributes << to_array.join(';')

        attributes == ';' ? '' : attributes
      end

      # @return [String]
      def to_string_short
        any? ? ";attributes=#{names.keys.collect { |key| name_w_props(key) }.join(' ').inspect}" : ""
      end

      # @return [String]
      def to_text
        text = ""
        names.each_pair do |name, value|
          # TODO: find a better way to skip properties
          next if name.include? '._'
          case value
          when Occi::Core::Entity
            text << "\nX-OCCI-Attribute: #{name}=\"#{value.location}\""
          when Occi::Core::Category
            text << "\nX-OCCI-Attribute: #{name}=\"#{value.type_identifier}\""
          else
            text << "\nX-OCCI-Attribute: #{name}=#{value.inspect}"
          end
        end

        text
      end

      # @return [Array] of attributes put in an array
      def to_array
        attributes = []

        names.each_pair do |name, value|
          # TODO: find a better way to skip properties
          next if name.include? '._'
          case value
          when Occi::Core::Entity
            attributes << "#{name}=\"#{value.location}\""
          when Occi::Core::Category
            attributes << "#{name}=\"#{value.type_identifier}\""
          else
            attributes << "#{name}=#{value.inspect}"
          end
        end

        attributes
      end

      # @return [String] of attributes put in an array and then concatenated into a string
      def to_header
        to_array.join(',')
      end

      def to_json(*a)
        as_json(*a).to_json(*a)
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        hash = Hashie::Mash.new
        self.each_pair do |key, value|
          next if key =~ /^_/
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
            hash[key] = value.as_json unless value.nil?
          end
        end

        hash
      end

      # @param [Occi::Core::Attributes] definitions
      # @param [true,false] set_defaults
      # @return [Occi::Core::Attributes] attributes with their defaults set
      def check(definitions, set_defaults = false)
        attributes = Occi::Core::Attributes.new(self)
        attributes.check!(definitions, set_defaults)
        attributes
      end

      # @param [Occi::Core::Attributes] definitions
      # @param [true,false] set_defaults
      # Assigns default values to attributes
      def check!(definitions, set_defaults = false)
        raise Occi::Errors::AttributeDefinitionsConvrertedError,
              "Definition attributes must not be converted" if definitions.converted?

        # Start with checking for missing attributes
        add_missing_attributes(self, definitions, set_defaults)

        # Then check all attributes against definitions
        check_wrt_definitions(self, definitions, set_defaults)

        # Delete remaining empty attributes
        delete_empty(self)
      end

      private

      def validate_and_assign(key, value, property_key)
        raise Occi::Errors::AttributeNameInvalidError,
              "Attribute names (as in \"#{key}\") must not begin with underscores" if key =~ /^_/

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
          match_type(value, 'string', self[property_key]) if self[property_key]
          add_to_hashie(key, value)
        when Occi::Core::Category
          match_type(value, 'string', self[property_key]) if self[property_key]
          add_to_hashie(key, value)
        when String
          value = interpret_string(value, self[property_key]) if self[property_key]
          add_to_hashie(key, value)
        when Numeric
          match_type(value, 'number', self[property_key]) if self[property_key]
          add_to_hashie(key, value)
        when FalseClass, TrueClass
          match_type(value, 'boolean', self[property_key]) if self[property_key]
          add_to_hashie(key, value)
        when NilClass
          add_to_hashie(key, value)
        else
          raise Occi::Errors::AttributeTypeError,
                "Value #{value} of type #{value.class} not supported as attribute"
        end
      end

      def add_to_hashie(*args)
        Hashie::Mash.instance_method(:[]=).bind(self).call(*args)
      end

      def interpret_string(value, property)
        if property.type == 'number' && (/^[.0-9]+$/ =~ value)
          value = (/^[0-9]+$/ =~ value) ? value.to_i : value.to_f
          match_type(value, 'number', property)
        elsif property.type == 'boolean'
          value = if value.casecmp("yes") == 0 || value.casecmp("true") == 0
                    true
                  elsif value.casecmp("no") == 0 || value.casecmp("false") == 0
                    false
                  else
                    value
                  end

          match_type(value, 'boolean', property)
        else
          match_type(value, 'string', property)
        end

        value
      end

      def match_type(value, value_type, property)
        raise Occi::Errors::AttributeTypeError,
              "Value #{value} derived from #{value.class} assigned " \
              "but attribute of type #{property.type} required" unless property.type == value_type
        match_pattern(property.pattern, value)
      end

      def match_pattern(pattern, value)
        return if pattern.blank?

        if Occi::Settings.verify_attribute_pattern && !Occi::Settings.compatibility
          raise Occi::Errors::AttributeTypeError,
                "Value #{value.to_s} does not match pattern #{pattern}" unless value.to_s.match "^#{pattern}$"
        else
          Occi::Log.debug "[#{self.class}] Skipping pattern checks on attributes, turn off " \
                         "the compatibility mode and enable the attribute pattern check in settings!"
        end
      end

      def add_missing_attributes(attributes, definitions, set_defaults)
        attributes ||= Occi::Core::Attributes.new

        definitions.each_key do |key|
          next if key =~ /^_/

          if definitions[key].kind_of? Occi::Core::Attributes
            add_missing_attributes(attributes[key], definitions[key], set_defaults)
          elsif attributes[key].nil?

            if definitions[key].default.nil?
              raise Occi::Errors::AttributeMissingError,
                    "Required attribute #{key} not specified" if definitions[key].required
            else
              attributes[key] = definitions[key].default if definitions[key].required || set_defaults
            end

          end
        end
      end

      def check_wrt_definitions(attributes, definitions, set_defaults)
        attributes.each_key do |key|
          next if key =~ /^_/

          #Raise exception for attributes not defined at all
          raise Occi::Errors::AttributeNotDefinedError,
                "Attribute #{key} not found in definitions" unless definitions.key?(key)

          if attributes[key].kind_of? Occi::Core::Attributes
            check_wrt_definitions(attributes[key], definitions[key], set_defaults)
          else
            next if attributes[key].nil? # I will be removed in the next step

            #Check value types
            definitions[key].check_value_for_type(attributes[key], key)

            # Check patterns
            if definitions[key].pattern
              if Occi::Settings.verify_attribute_pattern && !Occi::Settings.compatibility
                raise Occi::Errors::AttributeTypeError,
                      "Attribute #{key} with value #{attributes[key]} does not " \
                      "match pattern #{definitions[key].pattern}" unless attributes[key].to_s.match "^#{definitions[key].pattern}$"
              else
                Occi::Log.debug "[#{self.class}] [#{key}] Skipping pattern checks on attributes, turn off " \
                               "the compatibility mode and enable the attribute pattern check in settings!"
              end
            end
          end
        end
      end

      def delete_empty(attributes)
        attributes.each_key do |key|
          if attributes[key].kind_of? Occi::Core::Attributes
            delete_empty(attributes[key])
          else
            attributes.delete(key) if attributes[key].nil?
          end
        end
      end

      def name_w_props(attribute_name)
        return attribute_name if attribute_name.blank?

        parts = attribute_name.split('.')
        parts[parts.length - 1] = "_#{parts.last}"
        property_name = parts.join('.')

        return attribute_name unless self[property_name]

        props = []
        props << "immutable" if !self[property_name].mutable
        props << "required" if self[property_name].required

        attribute_name = "#{attribute_name}{#{props.join(' ')}}" unless props.empty?

        attribute_name
      end

    end
  end
end
