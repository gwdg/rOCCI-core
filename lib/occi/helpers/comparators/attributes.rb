module Occi
  module Helpers
    module Comparators
      module Attributes

        def ==(obj)
          return false unless obj && obj.respond_to?(:names)
          self.names == obj.names
        end

        def eql?(obj)
          self == obj
        end

        def hash
          self.names.hash
        end

      end
    end
  end
end