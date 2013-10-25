module Occi
  module Helpers
    module Comparators
      module Entity

        def ==(obj)
          return false unless obj && obj.respond_to?(:kind) && obj.respond_to?(:attributes)
          (self.kind == obj.kind) && (self.attributes['occi.core.id'] == obj.attributes['occi.core.id'])
        end

        def eql?(obj)
          self == obj
        end

        def hash
          [self.kind, self.attributes['occi.core.id']].hash
        end

      end
    end
  end
end