require 'occi/core/renderers/text/base'
require 'occi/core/renderers/text/category'

module Occi
  module Core
    module Renderers
      module Text
        # Implements methods needed to render model instances to text-based
        # renderings. This class (its instances) is usually called directly from
        # the "outside". It utilizes `Category` from this module to render kinds,
        # actions, and mixins.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Model < Base
          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            rcats = object.categories.collect { |cat| Category.new(cat, options).render }
            rcats.join("\n")
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            rcats = { Category.category_key_headers => [] }
            object.categories.each do |cat|
              rcats[Category.category_key_headers].concat(
                Category.new(cat, options).render[Category.category_key_headers]
              )
            end
            rcats
          end
        end
      end
    end
  end
end
