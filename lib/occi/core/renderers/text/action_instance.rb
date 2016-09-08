require 'occi/core/renderers/text/base'
require 'occi/core/renderers/text/instance'

module Occi
  module Core
    module Renderers
      module Text
        # Implements methods needed to render action instances to text-based
        # renderings. This class (its instances) is usually called directly from
        # the "outside". It utilizes `Category` and `Attributes` from this module
        # to render actions and instance attributes.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class ActionInstance < Base
          include Instance

          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            short_category(object.action) << "\n" << instance_attributes
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            short_category(object.action).merge(instance_attributes)
          end
        end
      end
    end
  end
end
