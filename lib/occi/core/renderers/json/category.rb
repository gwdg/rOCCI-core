require 'occi/core/renderers/json/base'

module Occi
  module Core
    module Renderers
      module Json
        # Implements routines required to render `Occi::Core::Category` and
        # its subclasses to a JSON-based representation.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Category < Base
          # Typecasting constants
          # TODO: fix this damn typing mess (add at least MACAddr, IPAddr, URI, Float, and Integer)
          STRING  = 'string'.freeze
          NUMBER  = 'number'.freeze
          BOOLEAN = 'boolean'.freeze
          ARRAY   = 'array'.freeze
          OBJECT  = 'object'.freeze

          TYPECASTER_HASH = {
            IPAddr => STRING, URI => STRING, String => STRING,
            Float => NUMBER, Numeric => NUMBER, Integer => NUMBER,
            Boolean => BOOLEAN, Array => ARRAY, Hash => OBJECT
          }.freeze

          # Renders the given object to `JSON`.
          #
          # @return [String] object rendering as JSON
          def render
            render_hash.to_json
          end

          # :nodoc:
          def render_hash
            hash = {}

            add_basics! hash
            add_extended! hash
            add_attributes! hash

            hash
          end

          # :nodoc:
          def add_basics!(hash)
            hash[:term] = object.term
            hash[:scheme] = object.schema
            hash[:location] = object.location.to_s if object_respond_to?(:location)
            hash[:title] = object.title if object.title
          end

          # :nodoc:
          def add_extended!(hash)
            hash[:parent] = object_parent.to_s if object_respond_to?(:parent)
            %i[actions depends applies].each do |symbol|
              next unless object_respond_to?(symbol) && !object_send(symbol).blank?
              hash[symbol] = object_send(symbol).collect(&:to_s)
            end
          end

          # :nodoc:
          def add_attributes!(hash)
            return if object_attributes.blank?
            hash[:attributes] = {}
            object_attributes.each_pair do |key, value|
              hash[:attributes][key] = definition_to_hash(value)
            end
          end

          # @param attr_defn [Occi::Core::AttributeDefinition] attribute definition to convert
          # @return [Hash] covnerted hash
          def definition_to_hash(attr_defn)
            hattr = {
              mutable: attr_defn.mutable?,
              required: attr_defn.required?,
              type: typecast(attr_defn.type)
            }

            hattr[:pattern] = attr_defn.pattern unless attr_defn.pattern.nil?
            hattr[:default] = attr_defn.default unless attr_defn.default.nil?
            hattr[:description] = attr_defn.description if attr_defn.description

            hattr
          end

          # :nodoc:
          def object_respond_to?(symbol)
            object.respond_to? symbol
          end

          # :nodoc:
          def object_send(symbol)
            object.send symbol
          end

          # :nodoc:
          def object_parent
            object.parent
          end

          # :nodoc:
          def object_attributes
            object.attributes
          end

          # :nodoc:
          def typecast(type)
            TYPECASTER_HASH[type] || raise("#{self.class} -> Cannot typecast #{type.inspect} to a known OCCI type")
          end
        end
      end
    end
  end
end
