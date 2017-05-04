module Occi
  module Core
    module Errors
      # Custom error class indicating internal parser
      # errors or non-compliance with the expected interface.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class ParserError < StandardError; end
    end
  end
end
