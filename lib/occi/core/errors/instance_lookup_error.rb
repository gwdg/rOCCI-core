module Occi
  module Core
    module Errors
      # Custom error class indicating look-up failures on
      # instances.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class InstanceLookupError < StandardError; end
    end
  end
end
