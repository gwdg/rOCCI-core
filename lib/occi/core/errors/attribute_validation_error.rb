require 'occi/core/errors/validation_error'

module Occi
  module Core
    module Errors
      # Custom error class indicating validation failures on
      # attribute values.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class AttributeValidationError < ValidationError; end
    end
  end
end
