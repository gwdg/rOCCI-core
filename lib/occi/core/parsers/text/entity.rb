module Occi
  module Core
    module Parsers
      module Text
        # Static parsing class responsible for extracting entities from plain text.
        # Class supports 'text/plain' via `plain`. No other formats are supported.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Entity
          include Yell::Loggable
          include Helpers::ErrorHandler

          # Regexp constants
          ATTRIBUTE_REGEXP = /#{Constants::REGEXP_ATTRIBUTE}/
          LINK_REGEXP      = /#{Constants::REGEXP_LINK}/

          # Typecasting lambdas
          RESOURCE_LAMBDA = lambda do |val, model|
            model.instance_builder.build(
              Occi::Core::Constants::RESOURCE_KIND,
              id: val.split('/').last, location: val, title: 'Generated resource'
            )
          end
          CATEGORY_LAMBDA = ->(val, model) { model.find_by_identifier! val }
          IPADDR_LAMBDA   = ->(val, _) { IPAddr.new val }
          URI_LAMBDA      = ->(val, _) { URI.parse val }
          FLOAT_LAMBDA    = ->(val, _) { val.to_f }
          INTEGER_LAMBDA  = ->(val, _) { val.to_i }
          BOOLEAN_LAMBDA  = ->(val, _) { val.casecmp 'true' }
          STRING_LAMBDA   = ->(val, _) { val }
          DEFAULT_LAMBDA  = ->(val, _) { raise "Cannot typecast #{val.inspect} to an unknown type" }

          class << self
            # TODO: docs
            # @param lines [Array]
            # @param model [Occi::Core::Model]
            # @return [Occi::Core::Entity]
            def plain(lines, model)
              cats = plain_categories(lines, model)

              kind = cats.detect { |c| c.is_a?(Occi::Core::Kind) }
              raise Occi::Core::Errors::ParsingError, "#{self} -> Entity does not specify its kind" unless kind

              entity = model.instance_builder.build(kind.identifier)
              cats.each { |cat| cat.is_a?(Occi::Core::Mixin) && entity << cat }

              plain_attributes! lines, entity.attributes, model
              # TODO: links
              # TODO: actions

              entity
            end

            # TODO: docs
            # @param lines [Array]
            # @param model [Occi::Core::Model]
            # @return [Array]
            def plain_categories(lines, model)
              lines.map do |line|
                next unless line.start_with?(TextParser::CATEGORY_KEYS.first)
                cat = Category.plain_category(line, false)
                handle(Occi::Core::Errors::ParsingError) { model.find_by_identifier!("#{cat[:scheme]}#{cat[:term]}") }
              end.compact
            end

            # TODO: docs
            # @param lines [Array]
            # @param attributes [Hash]
            # @param model [Occi::Core::Model]
            # @return [Hash]
            def plain_attributes!(lines, attributes, model)
              lines.each do |line|
                next unless line.start_with?(TextParser::ATTRIBUTE_KEYS.first)
                name, value = raw_attribute(line)
                unless attributes[name]
                  raise Occi::Core::Errors::ParsingError,
                        "#{self} -> attribute #{name.inspect} is not allowed for this entity"
                end
                attributes[name].value = handle(Occi::Core::Errors::ParsingError) do
                  typecast value, attributes[name].attribute_definition.type, model
                end
              end
              attributes
            end

            # TODO: docs
            # @param line [String]
            # @return [Array]
            def raw_attribute(line)
              matched = line.match(ATTRIBUTE_REGEXP)
              unless matched
                raise Occi::Core::Errors::ParsingError,
                      "#{self} -> #{line.inspect} does not match expectations for Attribute"
              end
              [matched[:name], matched[:string] || matched[:number] || matched[:bool]]
            end

            # TODO: docs
            # @param lines [Array]
            # @return [Array]
            def plain_links(lines)
              lines.map do |line|
                next unless line.start_with?(TextParser::LINK_KEYS.first)
                matched = line.match(LINK_REGEXP)
                unless matched
                  raise Occi::Core::Errors::ParsingError,
                        "#{self} -> #{line.inspect} does not match expectations for Link"
                end
              end.compact
            end

            # TODO: docs
            # @param value [String]
            # @param type [Class,Module]
            # @param model [Occi::Core::Model]
            # @return [Object]
            def typecast(value, type, model)
              if value.nil? || type.nil?
                raise Occi::Core::Errors::ParsingError,
                      'Cannot typecast (un)set value to (un)set type'
              end

              typecaster[type].call(value, model)
            end

            # TODO: docs
            # @return [Hash]
            def typecaster
              typecaster_hash = Hash.new(DEFAULT_LAMBDA)
              typecaster_hash[Occi::Core::Resource] = RESOURCE_LAMBDA
              typecaster_hash[Occi::Core::Category] = CATEGORY_LAMBDA
              typecaster_hash[IPAddr] = IPADDR_LAMBDA
              typecaster_hash[URI] = URI_LAMBDA
              typecaster_hash[String] = STRING_LAMBDA
              typecaster_hash[Float] = FLOAT_LAMBDA
              typecaster_hash[Numeric] = FLOAT_LAMBDA
              typecaster_hash[Integer] = INTEGER_LAMBDA
              typecaster_hash[Boolean] = BOOLEAN_LAMBDA
              typecaster_hash
            end
          end
        end
      end
    end
  end
end
