module Occi
  module Core
    class Properties

      include Occi::Helpers::Inspect
      include Occi::Helpers::Comparators::Properties

      PROPERTY_KEYS = [:type, :required, :mutable, :default, :description, :pattern]
      attr_accessor :type, :required, :mutable, :default, :description, :pattern
      alias_method :required?, :required
      alias_method :mutable?, :mutable

      # @param source_hash [Hash]
      def initialize(source_hash = {})
        raise ArgumentError, 'Source_hash must be initialized from a hash-like structure!' unless source_hash.kind_of?(Hash)
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
