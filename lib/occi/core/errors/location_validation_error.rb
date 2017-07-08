require 'occi/core/errors/validation_error'

module Occi
  module Core
    module Errors
      # Custom error class indicating validation failures on
      # various Core class instances.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class LocationValidationError < ValidationError; end
    end
  end
end
