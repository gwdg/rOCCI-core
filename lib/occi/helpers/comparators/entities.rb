module Occi
  module Helpers
    module Comparators
      module Entities

        def ==(obj)
          return false unless obj && obj.respond_to?(:to_a)
          self.to_a == obj.to_a
        end

        def eql?(obj)
          self == obj
        end

        def hash
          self.to_a.hash
        end

      end
    end
  end
end