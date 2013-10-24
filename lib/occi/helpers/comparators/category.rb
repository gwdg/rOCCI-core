module Occi
  module Helpers
    module Comparators
      module Category

        def ==(obj)
          return false unless obj && obj.respond_to?(:type_identifier)
          self.type_identifier == obj.type_identifier
        end

        def eql?(obj)
          self == obj
        end

        def hash
          self.type_identifier.hash
        end

      end
    end
  end
end