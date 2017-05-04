module Occi
  module Core
    module Errors
      # Custom error class indicating issues with mandatory arguments and
      # their format/content.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class MandatoryArgumentError < ArgumentError; end
    end
  end
end
