require 'occi/core/renderers/text/base'

module Occi
  module Core
    module Renderers
      module Text
        # Implements routines required to render `Occi::Core::Category` and
        # its subclasses to a text-based representation. Supports rendering
        # to plain and header-like formats. Internally, the rendering itself
        # is done via ERB templates.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Category < Base
          # Category key constants
          CATEGORY_KEY_PLAIN = 'Category'.freeze
          CATEGORY_KEY_HEADERS = 'X-OCCI-Category'.freeze

          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            obj_data = object_data
            "#{CATEGORY_KEY_PLAIN}: #{erb_render(obj_data)}"
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            obj_data = object_data
            { CATEGORY_KEY_HEADERS => [erb_render(obj_data)] }
          end

          # Returns keyword used to prefix all categories rendered to plain text.
          #
          # @return [String] category keyword
          def category_key_plain
            CATEGORY_KEY_PLAIN
          end

          # Returns word used to key all categories rendered to headers.
          #
          # @return [String] category key
          def category_key_headers
            CATEGORY_KEY_HEADERS
          end

          class << self
            # Returns keyword used to prefix all categories rendered to plain text.
            #
            # @return [String] category keyword
            def category_key_plain
              CATEGORY_KEY_PLAIN
            end

            # Returns word used to key all categories rendered to headers.
            #
            # @return [String] category key
            def category_key_headers
              CATEGORY_KEY_HEADERS
            end
          end

          private

          # :nodoc:
          def short?
            options[:type] == 'short'
          end

          # :nodoc:
          def long?
            !short?
          end

          # :nodoc:
          def object_data
            {
              term: object.term, schema: object.schema,
              subclass: prepare_subclass, title: object.title,
              rel: prepare_parent, location: prepare_location,
              attributes: prepare_attributes, actions: prepare_actions
            }
          end

          # :nodoc:
          def prepare_parent
            cand = if object.respond_to?(:directly_related)
                     prepare_kind_rel
                   elsif object.respond_to?(:depends) && object.respond_to?(:applies)
                     prepare_mixin_rel.to_a
                   end
            cand.compact! if cand

            cand.blank? ? nil : cand.collect(&:identifier).join(' ')
          end

          # :nodoc:
          def prepare_kind_rel
            [object.directly_related.first]
          end

          # :nodoc:
          def prepare_mixin_rel
            object.depends + object.applies
          end

          # :nodoc:
          def prepare_subclass
            object.class.name.demodulize.downcase
          end

          # :nodoc:
          def prepare_location
            object.respond_to?(:location) ? object.location : nil
          end

          # :nodoc:
          def prepare_attributes
            return unless object.respond_to?(:attributes)
            attrs = object.attributes.collect do |key, attr_def|
              key + prepare_attribute_def(attr_def)
            end

            attrs.empty? ? nil : attrs.join(' ')
          end

          # :nodoc:
          def prepare_attribute_def(attr_def)
            return '' unless attr_def.required? || attr_def.immutable?
            defs = []
            defs << 'required' if attr_def.required?
            defs << 'immutable' if attr_def.immutable?
            "{#{defs.join(' ')}}"
          end

          # :nodoc:
          def prepare_actions
            return unless object.respond_to?(:actions)
            acts = object.actions.collect(&:identifier)
            acts.empty? ? nil : acts.join(' ')
          end

          # :nodoc:
          def erb_render(obj_data)
            ERB.new(self.class.template, render_safe).result(binding)
          end

          class << self
            # Returns a static ERB template used to render `Category`-like
            # instances to plain text.
            #
            # @return [String] ERB template
            def template
              '<%= obj_data[:term] %>; ' \
              'scheme="<%= obj_data[:schema] %>"; ' \
              'class="<%= obj_data[:subclass] %>"' \
              '<% if long? && obj_data[:title] %>; title="<%= obj_data[:title] %>"<% end %>' \
              '<% if long? && obj_data[:rel] %>; rel="<%= obj_data[:rel] %>"<% end %>' \
              '<% if long? && obj_data[:location] %>; location="<%= obj_data[:location] %>"<% end %>' \
              '<% if long? && obj_data[:attributes] %>; attributes="<%= obj_data[:attributes] %>"<% end %>' \
              '<% if long? && obj_data[:actions] %>; actions="<%= obj_data[:actions] %>"<% end %>'
            end
          end
        end
      end
    end
  end
end
