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
          # :nodoc:
          def render_hash
            hsh = {}
            %i[actions kinds mixins].each do |symbol|
              next if object_send(symbol).blank?
              hsh[symbol] = object_send(symbol).collect { |k| Category.new(k, options).render_hash }
            end
            hsh
          end
        end
      end
    end
  end
end
