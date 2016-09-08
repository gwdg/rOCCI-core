require 'occi/core/renderers/text/category'
require 'occi/core/renderers/text/attributes'

module Occi
  module Core
    module Renderers
      module Text
        # Implements methods needed to render multiple instance types to text-based
        # renderings.
        #
        # @author Boris Parak <parak@cesnet.cz>
        module Instance
          # :nodoc:
          def instance_attributes
            Attributes.new(
              object.attributes, options
            ).render
          end

          # :nodoc:
          def short_category(category)
            Category.new(
              category, options.merge(type: 'short')
            ).render
          end

          # :nodoc:
          def short_mixins_plain
            object.mixins.collect { |mxn| short_category(mxn) }
          end

          # :nodoc:
          def short_mixins_headers
            object.mixins.collect do |mxn|
              short_category(mxn)[Category.category_key_headers]
            end.flatten
          end

          protected :instance_attributes, :short_category, :short_mixins_plain, :short_mixins_headers
        end
      end
    end
  end
end
