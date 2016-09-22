require 'occi/core/renderers/text/base'
require 'occi/core/renderers/text/instance'

module Occi
  module Core
    module Renderers
      module Text
        # Implements methods needed to render resource instances to text-based
        # renderings. This class (its instances) is usually called directly from
        # the "outside". It utilizes `Category` and `Attributes` from this module
        # to render kind, mixins, and instance attributes.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Resource < Base
          include Instance

          # Link key constant
          LINK_KEY = 'Link'.freeze

          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            [
              short_category(object.kind), short_mixins_plain, instance_attributes,
              instance_links, instance_actions
            ].flatten.join("\n")
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            headers = short_category(object.kind)
            headers[Category.category_key_headers].concat(
              short_mixins_headers
            )
            headers.merge!(instance_attributes)
            headers.merge!(header_links)

            headers
          end

          protected

          # :nodoc:
          def header_links
            { LINK_KEY => instance_links(false).concat(instance_actions(false)) }
          end

          # :nodoc:
          def instance_links(plain = true)
            links = object.links.collect { |link| instance_link(link) }
            plain ? links.map { |link| "#{LINK_KEY}: #{link}" } : links
          end

          # :nodoc:
          def instance_link(link)
            link_categories = instance_link_categories(link)
            link_attributes = instance_link_attributes(link)

            ERB.new(self.class.link_template, render_safe).result(binding)
          end

          # :nodoc:
          def instance_link_categories(link)
            [link.kind.identifier, *link.mixins.collect(&:identifier)].join(' ')
          end

          # :nodoc:
          def instance_link_attributes(link)
            attr_hash = Attributes.new(link.attributes, format: 'headers').render
            attr_hash.values.flatten.join('; ')
          end

          # :nodoc:
          def instance_actions(plain = true)
            actions = object.actions.collect { |action| instance_action(action) }
            plain ? actions.map { |action| "#{LINK_KEY}: #{action}" } : actions
          end

          # :nodoc:
          def instance_action(action)
            ERB.new(self.class.action_template, render_safe).result(binding)
          end

          class << self
            # :nodoc:
            def action_template
              '<<%= object.location %>?action=<%= action.term %>>; rel="<%= action %>"'
            end

            # :nodoc:
            def link_template
              '<<%= link.target.location %>>; ' \
              'rel="<%= link.target.kind %>"; ' \
              'self="<%= link.location %>"; ' \
              'category="<%= link_categories %>"; ' \
              '<%= link_attributes %>'
            end
          end
        end
      end
    end
  end
end
