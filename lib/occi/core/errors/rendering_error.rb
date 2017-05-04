module Occi
  module Core
    module Errors
      # Custom error class indicating rendering failures on
      # various renderable instances.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class RenderingError < StandardError; end
    end
  end
end
