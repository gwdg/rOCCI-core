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
            return {} if object_empty? || object.only_categories?

            if ent_no_ai?
              render_entities_hash
            elsif ai_no_ent?
              render_action_instances_hash
            else
              raise Occi::Core::Errors::RenderingError, 'Cannot render mixed collection to JSON'
            end
          end

          # :nodoc:
          def render_entities_hash
            hsh = {}
            if object_resources.any?
              hsh[:resources] = object_resources.collect { |r| Resource.new(r, options).render_hash }
            end
            if object_links.any?
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

          # :nodoc:
          def ent_no_ai?
            object_entities.any? && object_action_instances.empty?
          end

          # :nodoc:
          def ai_no_ent?
            object_action_instances.any? && object_entities.empty?
          end
        end
      end
    end
  end
end
