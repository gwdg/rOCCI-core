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
        Occi::Infrastructure::Warehouse.bootstrap! self
      end
    end
  end
end
