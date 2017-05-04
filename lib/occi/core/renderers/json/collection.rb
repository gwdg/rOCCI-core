require 'occi/core/renderers/json/model'
require 'occi/core/renderers/json/action_instance'
require 'occi/core/renderers/json/link'
require 'occi/core/renderers/json/resource'

module Occi
  module Core
    module Renderers
      module Json
        # Implements routines required to render `Occi::Core::Collection` and
        # its subclasses to a JSON-based representation.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Collection < Model
          # :nodoc:
          def render_hash
            return {} if object_empty?
            return super if object.only_categories?

            if object.only_entities?
              render_entities_hash
            elsif object.only_action_instances?
              render_action_instances_hash
            else
              raise Occi::Core::Errors::RenderingError, 'Cannot render mixed collection to JSON'
            end
          end

          # :nodoc:
          def render_entities_hash
            hsh = {}
            unless object_resources.blank?
              hsh[:resources] = object_resources.collect { |r| Resource.new(r, options).render_hash }
            end
            unless object_links.blank?
              hsh[:links] = object_links.collect { |r| Link.new(r, options).render_hash }
            end
            hsh
          end

          # :nodoc:
          def render_action_instances_hash
            if object_action_instances.count > 1
              raise Occi::Core::Errors::RenderingError, 'Cannot render multiple action instances to JSON'
            end
            ActionInstance.new(object_action_instances.first, options).render_hash
          end
        end
      end
    end
  end
end
