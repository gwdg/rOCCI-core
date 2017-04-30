require 'occi/core/renderers/json/base'
require 'occi/core/renderers/json/link'

module Occi
  module Core
    module Renderers
      module Json
        # Implements routines required to render `Occi::Core::Resource` and
        # its subclasses to a JSON-based representation.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Resource < Base
          include Instance

          # :nodoc:
          def render_hash
            base = render_instance_hash
            base[:summary] = object_summary if object_summary
            base[:links] = object_links.collect { |l| Link.new(l, options).render_hash } unless object_links.blank?
            base
          end
        end
      end
    end
  end
end
