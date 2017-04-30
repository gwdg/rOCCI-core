require 'occi/core/renderers/json/attributes'

module Occi
  module Core
    module Renderers
      module Json
        # Implements methods needed to render multiple instance types to JSON-based
        # renderings.
        #
        # @author Boris Parak <parak@cesnet.cz>
        module Instance
          # :nodoc:
          def render_instance_hash
            hsh = {}

            hsh[:kind] = object_kind.to_s
            %i[mixins actions].each do |symbol|
              hsh[symbol] = object_send(symbol).collect(&:to_s) unless object_send(symbol).blank?
            end

            hsh[:attributes] = render_attributes_hash unless object_attributes.blank?

            %i[id title].each do |symbol|
              next unless object_send(symbol)
              hsh[symbol] = object_send(symbol)
            end

            hsh
          end

          # :nodoc:
          def render_attributes_hash
            Attributes.new(object_attributes, options).render_hash
          end
        end
      end
    end
  end
end
