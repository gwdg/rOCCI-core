module Occi
  module Core
    module Errors
      # Custom error class indicating look-up failures on
      # model instances.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class ModelLookupError < StandardError; end
    end
  end
end
