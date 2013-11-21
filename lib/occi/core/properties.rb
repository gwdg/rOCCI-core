module Occi
  module Core
    class Properties

      include Occi::Helpers::Inspect
      include Occi::Helpers::Comparators::Properties

      PROPERTY_KEYS = [:type, :required, :mutable, :default, :description, :pattern]
      attr_accessor :required, :mutable, :default, :description, :pattern
      attr_reader :type
      alias_method :required?, :required
      alias_method :mutable?, :mutable

      # Types supported in properties, and their mapping to Ruby Classes
      SupportedTypes = Hash.new
      SupportedTypes["string"]  =  [ String ]
      SupportedTypes["number"]  =  [ Numeric ]
      SupportedTypes["boolean"] =  [ TrueClass, FalseClass ]

      def type=(type)
        unless SupportedTypes.key?(type)
          suptypes=""
          SupportedTypes.each_key { |key| suptypes="#{suptypes} \"#{key}\"" }
          raise Occi::Errors::AttributePropertyTypeError, "Type \"#{type}\" unsupported in properties. Supported types are:#{suptypes}."
        end
        @type = type
      end

      def check_value_for_type(value)
        raise Occi::Errors::AttributePropertyTypeError,
          "property type #{definitions[key].type} is not one of the allowed types number, boolean or string" unless SupportedTypes.key?(@type)
        raise Occi::Errors::AttributeTypeError,
          "Attribute value #{value} is class #{value.class.name}. It does not match attribute property type #{@type}" unless SupportedTypes[@type].any? { |klasse| value.kind_of?(klasse) }
      end

      # @param source_hash [Hash]
      def initialize(source_hash = {})
        raise ArgumentError, 'Source_hash must be initialized from a hash-like structure!' unless source_hash.kind_of?(Hash)
        raise ArgumentError, 'Source_hash must not be a Hashie::Mash instance!' if source_hash.kind_of?(Hashie::Mash)
        source_hash = Occi::Core::Properties.normalize_props(source_hash)

        self.type = source_hash[:type] ||= 'string'
        self.required = source_hash[:required] = source_hash[:required].nil? ? false : source_hash[:required]
        self.mutable = source_hash[:mutable] = source_hash[:mutable].nil? ? false : source_hash[:mutable]
        self.pattern = source_hash[:pattern] ||= '.*'
        self.description = source_hash[:description]
        self.default = source_hash[:default]
      end

      def to_hash
        as_json.to_hash
      end

      def to_json(*a)
        as_json(*a).to_json(*a)
      end

      def as_json(options={})
        hash = Hashie::Mash.new
        hash.default = self.default if self.default
        hash.type = self.type if self.type
        hash.required = self.required unless self.required.nil?
        hash.mutable = self.mutable unless self.mutable.nil?
        hash.pattern = self.pattern if self.pattern
        hash.description = self.description if self.description

        hash
      end

      # @return [Bool] Indicating whether this set of properties is "empty", i.e. no attributes are set
      def empty?
        as_json.empty?
      end

      def self.normalize_props(hash)
        props = {}

        PROPERTY_KEYS.each do |key|
          found = hash.keys.select { |k| k.to_s.downcase.to_sym == key }.first
          props[key] = hash[found] if found
        end

        props
      end

      def self.contains_props?(hash)
        # Not a hash == doesn't contain Properties
        return false unless hash.kind_of? Hash
        hash = normalize_props(hash)

        # Are there any Property keys?
        return false if hash.empty?

        # Do all Property keys point to simple values?
        complx_keys = hash.keys.select { |k| hash[k].kind_of?(Hash) }
        return false unless complx_keys.empty?

        true
      end
    end
  end
end
