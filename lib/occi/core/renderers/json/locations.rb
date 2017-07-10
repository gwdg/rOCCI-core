require 'occi/core/renderers/json/base'

module Occi
  module Core
    module Renderers
      module Json
        # Implements routines required to render `Occi::Core::Locations` and
        # its subclasses to a JSON-based representation.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Locations < Base
          # :nodoc:
          def render_hash
            object.map(&:to_s)
          end
        end
      end
    end
  end
end
