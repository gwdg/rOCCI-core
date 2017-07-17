require 'occi/core/renderers/text/model'

module Occi
  module Core
    module Renderers
      module Text
        # Implements methods needed to render collection instances to text-based
        # renderings. This class (its instances) is usually called directly from
        # the "outside". It utilizes `Model` from this module to render kinds,
        # actions, and mixins. As well as `Resource`, `Link`, and `ActionInstance`.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Collection < Model
          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            return '' if object_empty? || object.only_categories?

            if ent_no_ai?
              prepare_instances 'entities'
            elsif ai_no_ent?
              prepare_instances 'action_instances'
            else
              raise Occi::Core::Errors::RenderingError,
                    'Cannot render mixed collection to plain text'
            end
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            return {} if object_empty? || object.only_categories?

            if ent_no_ai?
              prepare_instances 'entities'
            elsif ai_no_ent?
              prepare_instances 'action_instances'
            else
              raise Occi::Core::Errors::RenderingError,
                    'Cannot render mixed collection to text headers'
            end
          end

          private

          # :nodoc:
          def prepare_instances(type)
            if object_send(type).count > 1
              raise Occi::Core::Errors::RenderingError,
                    "Cannot render collection with multiple #{type.tr('_', ' ')} to text"
            end

            Occi::Core::Renderers::TextRenderer.render object_send(type).first, options
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
