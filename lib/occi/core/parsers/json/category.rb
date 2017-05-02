module Occi
  module Core
    module Parsers
      module Json
        # Static parsing class responsible for extracting categories from JSON.
        # Class supports 'application/json' via `json`. No other formats are supported.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Category
          include Yell::Loggable
          extend Helpers::ParserDereferencer

          # Typecasting lambdas
          TYPECASTER_HASH = {
            'boolean' => Boolean,
            'string'  => String,
            'number'  => Numeric,
            'array'   => Array,
            'object'  => Hash
          }.freeze

          class << self
            # Parses categories into instances of subtypes of `Occi::Core::Category`. Internal references
            # between objects are converted from strings to actual objects. Categories provided in the model
            # will be reused but have to be declared in the parsed model as well.
            #
            # @param body [Array] JSON body for parsing
            # @param model [Occi::Core::Model] model with existing categories
            # @return [Occi::Core::Model] model with all known category instances
            def json(body, model)
              parsed = raw_hash(body)

              instantiate_hashes! parsed, model
              raw_categories = [parsed[:kinds], parsed[:mixins]].flatten.compact
              dereference_identifiers! model.categories, raw_categories

              model
            end

            # :nodoc:
            def raw_hash(body)
              JSON.parse body, symbolize_names: true
            rescue => ex
              raise Occi::Core::Errors::ParsingError, "#{self} -> #{ex.message}", ex
            end

            # :nodoc:
            def instantiate_hashes!(raw, model)
              raw[:kinds].each { |k| model << instatiate_hash(k, Occi::Core::Kind) } if raw[:kinds]
              raw[:mixins].each { |k| model << instatiate_hash(k, Occi::Core::Mixin) } if raw[:mixins]
              raw[:actions].each { |k| model << instatiate_hash(k, Occi::Core::Action) } if raw[:actions]
            end

            # :nodoc:
            def instatiate_hash(raw, klass)
              obj = klass.new(
                term: raw[:term], schema: raw[:scheme], title: raw[:title],
                attributes: attribute_definitions(raw[:attributes])
              )
              obj.location = URI.parse(raw[:location]) if obj.respond_to?(:location)
              obj
            end

            # :nodoc:
            def attribute_definitions(raw)
              return {} if raw.blank?
              attr_defs = {}
              raw.each_pair do |k, v|
                attr_defs[k.to_s] = Occi::Core::AttributeDefinition.new typecast(v)
              end
              attr_defs
            end

            # :nodoc:
            def typecast(hash)
              hash = hash.clone
              hash[:type] = TYPECASTER_HASH[hash[:type]]
              hash[:pattern] = Regexp.new(hash[:pattern]) if hash[:pattern]
              hash
            end
          end
        end
      end
    end
  end
end
