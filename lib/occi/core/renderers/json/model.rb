require 'occi/core/renderers/json/base'
require 'occi/core/renderers/json/category'

module Occi
  module Core
    module Renderers
      module Json
        # Implements routines required to render `Occi::Core::Model` and
        # its subclasses to a JSON-based representation.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Model < Base
          # Renders the given object to `JSON`.
          #
          # @return [String] object rendering as JSON
          def render
            hs = {}
            %i[actions kinds mixins].each do |symbol|
              next if object.send(symbol).blank?
              hs[symbol] = object.send(symbol).collect { |k| Category.new(k, options).render_hash }
            end
            hs.to_json
          end
        end
      end
    end
  end
end
