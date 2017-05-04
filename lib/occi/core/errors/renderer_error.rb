module Occi
  module Core
    module Errors
      # Custom error class indicating internal renderer
      # errors or non-compliance with the expected interface.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class RendererError < StandardError; end
    end
  end
end
