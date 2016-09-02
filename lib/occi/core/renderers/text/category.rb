require 'occi/core/renderers/text/base'

module Occi
  module Core
    module Renderers
      module Text
        class Category < Base
          class << self
            # @return [String] textual representation of Category
            def render_plain(object, _options)
              obj_data = object_data(object)
              "Category: #{ERB.new(template, render_safe).result(binding)}"
            end

            # @return [Hash] hash-like textual representation of Category
            def render_headers(object, _options)
              obj_data = object_data(object)
              { 'X-OCCI-Category' => [ERB.new(template, render_safe).result(binding)] }
            end

            def object_data(object)
              {
                term: object.term, schema: object.schema,
                subclass: render_subclass(object), title: object.title,
                rel: render_parent(object),
                location: render_location(object),
                attributes: render_attributes(object),
                actions: render_actions(object)
              }
            end

            def render_parent(object)
              cand = if object.respond_to?(:directly_related)
                       object.directly_related.first
                     elsif object.respond_to?(:depends)
                       object.depends.first
                     end
              cand ? cand.identifier : nil
            end

            def render_subclass(object)
              object.class.name.demodulize.downcase
            end

            def render_location(object)
              object.respond_to?(:location) ? object.location : nil
            end

            def render_attributes(object)
              return unless object.respond_to?(:attributes)
              attrs = object.attributes.keys
              attrs.empty? ? nil : attrs.join(' ')
            end

            def render_actions(object)
              return unless object.respond_to?(:actions)
              acts = object.actions.collect(&:identifier)
              acts.empty? ? nil : acts.join(' ')
            end

            def template
              '<%= obj_data[:term] %>; ' \
              'scheme="<%= obj_data[:schema] %>"; ' \
              'class="<%= obj_data[:subclass] %>"; ' \
              'title="<%= obj_data[:title] %>"' \
              '<% if obj_data[:rel] %>; rel="<%= obj_data[:rel] %>"<% end %>' \
              '<% if obj_data[:location] %>; location="<%= obj_data[:location] %>"<% end %>' \
              '<% if obj_data[:attributes] %>; attributes="<%= obj_data[:attributes] %>"<% end %>' \
              '<% if obj_data[:actions] %>; actions="<%= obj_data[:actions] %>"<% end %>'
            end
          end
        end
      end
    end
  end
end
