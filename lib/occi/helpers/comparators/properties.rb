module Occi
  module Helpers
    module Comparators
      module Properties

        def ==(obj)
          return false unless obj && obj.respond_to?(:instance_variables)

          local_attrs = self.instance_variables.map { |ivar| self.instance_variable_get ivar }
          remote_attrs = obj.instance_variables.map { |ivar| obj.instance_variable_get ivar }

          local_attrs == remote_attrs
        end

        def eql?(obj)
          self == obj
        end

        def hash
          self.instance_variables.map { |ivar| self.instance_variable_get ivar }.hash
        end

      end
    end
  end
end