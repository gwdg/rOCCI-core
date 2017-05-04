module Occi
  module Core
    module Errors
      # Custom error class indicating validation failures on
      # various objects.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class ValidationError < StandardError; end
    end
  end
end
