module Occi
  module Core
    module Errors
      # Custom error class indicating validation failures on
      # attribute values.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class AttributeValidationError < StandardError; end
    end
  end
end
