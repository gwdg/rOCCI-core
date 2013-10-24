module Occi
  module Helpers
    module Comparators
      module Category

        def ==(obj)
          return false unless obj && obj.respond_to?(:scheme) && obj.respond_to?(:term)
          (self.scheme == obj.scheme) && (self.term == obj.term)
        end

        def eql?(obj)
          self == obj
        end

      end
    end
  end
end