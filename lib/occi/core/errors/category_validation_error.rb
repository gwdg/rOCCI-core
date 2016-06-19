require 'occi/core/errors/validation_error'

module Occi
  module Core
    module Errors
      # Custom error class indicating validation failures on
      # category instances.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class CategoryValidationError < ValidationError; end
    end
  end
end
