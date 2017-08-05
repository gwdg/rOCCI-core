require 'occi/core/renderers/json/base'

module Occi
  module Core
    module Renderers
      module Json
        # Implements routines required to pre-render instance attributes and
        # its subclasses to a JSON-based representation.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Attributes < Base
          # Typecasting lambdas
          DEFAULT_LAMBDA  = ->(val) { val }
          TYPECASTER_HASH = {
            IPAddr => ->(val) { val.host? ? val.to_s : "#{val}/#{val.cidr_mask}" },
            URI    => ->(val) { val.to_s }
          }.freeze

          # Renders the given object to `JSON`.
          #
          # @return [String] object rendering as JSON
          def render
            raise Occi::Core::Errors::RendererError, 'Cannot render a standalone instance attribute'
          end

          # :nodoc:
          def render_hash
            attrs = {}
            object.each_pair do |name, content|
              next unless content.value?
              attrs[name] = typecast(content.value, content.attribute_definition.type)
            end
            attrs
          end

          # :nodoc:
          def typecast(value, type)
            typecaster[type].call(value)
          end

          # :nodoc:
          def typecaster
            Hash.new(DEFAULT_LAMBDA).merge(TYPECASTER_HASH)
          end
        end
      end
    end
  end
end
