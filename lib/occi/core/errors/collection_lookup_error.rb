module Occi
  module Core
    module Errors
      # Custom error class indicating look-up failures on
      # collection instances.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class CollectionLookupError < StandardError; end
    end
  end
end
