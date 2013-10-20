module Occi
  module Core
    class Properties

      include Occi::Helpers::Inspect

      attr_accessor :default, :type, :required, :mutable, :pattern, :description
      alias_method :required?, :required
      alias_method :mutable?, :mutable

      # @param [Hash] properties
      # @param [Hash] default
      def initialize(properties={})
        self.default = properties[:default]
        self.type = properties[:type] ||= 'string'
        self.required = properties[:required] ||= false
        self.mutable = properties[:mutable] ||= false
        self.pattern = properties[:pattern] ||= '.*'
        self.description = properties[:description]
      end

      def as_json(options={})
        hash = Hashie::Mash.new
        hash.default = self.default if self.default
        hash.type = self.type if self.type
        hash.required = self.required if self.required
        hash.mutable = self.mutable if self.mutable
        hash.pattern = self.pattern if self.pattern
        hash.description = self.description if self.description

        hash
      end

    end
  end
end
