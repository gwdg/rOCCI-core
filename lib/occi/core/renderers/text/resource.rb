require 'occi/core/renderers/text/base'

module Occi
  module Core
    module Renderers
      module Text
        # Implements methods needed to render resource instances to text-based
        # renderings. This class (its instances) is usually called directly from
        # the "outside". It utilizes `Category` and `Attributes` from this module
        # to render kind, mixins, and instance attributes.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Resource < Base
          include Instance

          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            [
              short_category(object.kind), short_mixins_plain, instance_attributes,
              # TODO: instance_links, instance_actions
            ].flatten.join("\n")
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            headers = short_category(object.kind)
            headers[Category.category_key_headers].concat(
              short_mixins_headers
            )
            headers.merge(instance_attributes)
          end

          # protected

          # # :nodoc:
          # def instance_links
          # end

          # # :nodoc:
          # def instance_actions
          # end
        end
      end
    end
  end
end
