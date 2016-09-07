require 'occi/core/renderers/text/base'

module Occi
  module Core
    module Renderers
      module Text
        # Implements methods needed to render link instances to text-based
        # renderings. This class (its instances) is usually called directly from
        # the "outside". It utilizes `Category` and `Attributes` from this module
        # to render kind, mixins, and instance attributes.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Link < Base
          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            [short_kind, short_mixins_plain, instance_attributes].flatten.join("\n")
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            headers = short_kind
            headers[Occi::Core::Renderers::Text::Category::CATEGORY_KEY_HEADERS].concat(
              short_mixins_headers
            )
            headers.merge(instance_attributes)
          end

          private

          # :nodoc:
          def short_kind
            short_category object.kind
          end

          # :nodoc:
          def short_mixins_plain
            object.mixins.collect { |mxn| short_category(mxn) }
          end

          # :nodoc:
          def short_mixins_headers
            object.mixins.collect do |mxn|
              short_category(mxn)[Occi::Core::Renderers::Text::Category::CATEGORY_KEY_HEADERS]
            end.flatten
          end

          # :nodoc:
          def instance_attributes
            Occi::Core::Renderers::Text::Attributes.new(
              object.attributes, options
            ).render
          end

          # :nodoc:
          def short_category(category)
            Occi::Core::Renderers::Text::Category.new(
              category, options.merge(type: 'short')
            ).render
          end
        end
      end
    end
  end
end
