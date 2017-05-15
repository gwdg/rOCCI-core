module Occi
  module Infrastructure
    # See `Occi::Core::Model` for details.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Model < Occi::Core::Model
      # Loads OGF's OCCI Infrastructure Standard from `Occi::Infrastructure::Warehouse`.
      #
      # @example
      #    model = Occi::Infrastructure::Model.new
      #    model.load_infrastructure!
      def load_infrastructure!
        logger.debug "#{self.class}: Loading Infrastructure from Warehouse"
        Occi::Infrastructure::Warehouse.bootstrap! self
        self << Occi::Infrastructure::Mixins::OsTpl.new
        self << Occi::Infrastructure::Mixins::ResourceTpl.new
        nil
      end

      # Returns an instance of `Occi::Infrastructure::InstanceBuilder` associated with this model.
      #
      # @return [Occi::Infrastructure::InstanceBuilder] instance of IB
      def instance_builder
        Occi::Infrastructure::InstanceBuilder.new(model: self)
      end

      # Returns all mixins dependent on the base `os_tpl` mixin defined by OGF.
      #
      # @return [Set] set of mixins dependent on `os_tpl`
      def find_os_tpls
        find_dependent Occi::Infrastructure::Mixins::OsTpl.new
      end

      # Returns all mixins dependent on the base `resource_tpl` mixin defined by OGF.
      #
      # @return [Set] set of mixins dependent on `resource_tpl`
      def find_resource_tpls
        find_dependent Occi::Infrastructure::Mixins::ResourceTpl.new
      end
    end
  end
end
