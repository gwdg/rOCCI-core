module Occi
  module Helpers
    module Comparators
      module ActionInstance

        def ==(obj)
          return false unless obj && obj.respond_to?(:action) && obj.respond_to?(:attributes)
          (self.action == obj.action) && (self.attributes == obj.attributes)
        end

        def eql?(obj)
          self == obj
        end

      end
    end
  end
end