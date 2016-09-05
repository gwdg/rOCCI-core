require 'occi/core/renderers/text/base'
require 'occi/core/renderers/text/category'
require 'occi/core/renderers/text/attributes'

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
          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            short_category << "\n" << instance_attributes
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            short_category.merge(instance_attributes)
          end

          private

          # :nodoc:
          def short_category
            Occi::Core::Renderers::Text::Category.new(
              object.action, options.merge(type: 'short')
            ).render
          end

          # :nodoc:
          def instance_attributes
            Occi::Core::Renderers::Text::Attributes.new(
              object.attributes, options
            ).render
          end
        end
      end
    end
  end
end
