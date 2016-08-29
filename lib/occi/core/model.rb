module Occi
  module Core
    # Implements a generic envelope for all OCCI-related instances. This
    # class can be used directly for various reasons or, in a specific way,
    # as an ancestor for custom classes providing `Model`-like functionality.
    # Its primary purpose is to provide a tool for working with multiple
    # sets of different instance types, aid with their transport and validation.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Model < Collection
      include Helpers::Renderable

      def valid!; end
      def valid?; end
    end
  end
end
