module Occi
  module Core
    class Categories < Set

      include Occi::Helpers::Inspect
      include Occi::Helpers::Comparators::Categories

      attr_accessor :model

      def initialize(categories=[])
        categories.collect! { |category| convert category } if categories
        super categories
      end

      def <<(category)
        category = convert(category)
        category.model = @model if @model && !category.kind_of?(String)

        super(category)
      end

      def join(separator)
        self.to_a.join(separator)
      end

      # Returns a Set with all categories related to the specified category
      #
      # @param [Occi::Core::Category] category
      # @return [Occi::Core::Categories]
      def get_related_to(category)
        self.class.new select { |cat| cat.related_to? category }
      end

      # @param [Occi::Model] model
      # @return [Occi::Model]
      def model=(model)
        @model = model
        each { |category| category.model = model }
        collect! { |category| model.get_by_id(category.to_s) || category }
      end

      # @param [Hash] options
      # @return [Hashie::Mash] json representation
      def as_json(options={})
        self.to_a.as_json
      end

      def check
        each { |category| category.check }
      end

      private

      def convert(category)
        if category.kind_of?(String) && @model
          @model.get_by_id(category) || category
        else
          category
        end
      end

    end
  end
end