require 'occi/core/renderers/json/base'
require 'occi/core/renderers/json/attributes'

module Occi
  module Core
    module Renderers
      module Json
        # Implements routines required to render `Occi::Core::ActionInstance` and
        # its subclasses to a JSON-based representation.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class ActionInstance < Base
          # :nodoc:
          def render_hash
            hsh = {}
            hsh[:action] = object_action.to_s
            hsh[:attributes] = Attributes.new(object_attributes, options).render_hash unless object_attributes.blank?
            hsh
          end
        end
      end
    end
  end
end
