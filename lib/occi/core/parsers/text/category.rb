module Occi
  module Core
    module Parsers
      module Text
        # Static parsing class responsible for extracting categories from plain text.
        # Class supports 'text/plain' via `plain`. No other formats are supported.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Category
          include Yell::Loggable
          extend Helpers::ParserDereferencer

          # Regexp constants
          CATEGORY_REGEXP  = /#{Constants::REGEXP_CATEGORY}/
          ATTRIBUTE_REGEXP = /^#{Constants::REGEXP_ATTRIBUTE_DEF}$/

          # Hash constants for ParserDereferencer
          PARENT_KEY  = :rel
          APPLIES_KEY = :rel
          DEPENDS_KEY = :rel

          class << self
            # Parses category lines into instances of subtypes of `Occi::Core::Category`. Internal references
            # between objects are converted from strings to actual objects. Categories provided in the model
            # will be reused but have to be declared in the parsed model as well. This mechanism can be used to
            # introduce properly typed attribute definitions to 'plain/text'-based models.
            #
            # @param lines [Array] list of single-category lines
            # @param model [Occi::Core::Model] model with existing categories
            # @return [Occi::Core::Model] model with all known category instances
            def plain(lines, model)
              raw_categories = []

              lines.each do |line|
                raw_categories << plain_category(line)
                model << construct_instance(raw_categories.last)
              end
              dereference_identifiers! model.categories, raw_categories

              model
            end

            # Parses a single-category line into a raw category hash containing all the necessary
            # information for creating an instance.
            #
            # @param line [String] single-category line containing the definition
            # @param full [TrueClass, FalseClass] parse full definition, defaults to `true`
            # @return [Hash] raw category hash for further processing
            def plain_category(line, full = true)
              matched = line.match(CATEGORY_REGEXP)
              unless matched
                raise Occi::Core::Errors::ParsingError,
                      "#{self} -> #{line.inspect} does not match expectations for Category"
              end

              cat = matchdata_to_hash(matched)
              return cat unless full

              cat[:attributes] = plain_attributes(cat[:attributes]) if cat[:attributes]
              cat[:rel] = plain_identifiers(cat[:rel]) if cat[:rel]
              cat[:actions] = plain_identifiers(cat[:actions]) if cat[:actions]

              cat
            end

            # Parses a multi-attribute line into a multi-attribute hash. The resulting hash has
            # attribute names pointing to attribute definitions.
            #
            # @example
            #    plain_attributes 'occi.core.id{required immutable} occi.storage.size' # => {...}
            #
            # @param line [String] multi-attribute line from a category definition
            # @return [Hash] hash with attribute names pointing to attribute definitions
            def plain_attributes(line)
              # TODO: find a better approach to fixing split
              line.gsub!(/\{(immutable|required)\s+(required|immutable)\}/, '{\1_\2}')

              attributes = {}
              line.split.each { |attribute| attributes.merge! plain_attribute(attribute) }

              attributes
            end

            # Parses an attribute line into an attribute hash. The resulting hash has
            # the attribute name pointing to the attribute definition.
            #
            # @example
            #    plain_attribute 'occi.core.id{required immutable}' # => {...}
            #
            # @param line [String] single-attribute line from a category definition
            # @return [Hash] hash with attribute name pointing to attribute definition
            def plain_attribute(line)
              # TODO: find a better approach to fixing split
              line.gsub!(/\{(immutable|required)_(required|immutable)\}/, '{\1 \2}')

              matched = line.match(ATTRIBUTE_REGEXP)
              unless matched && matched[1]
                raise Occi::Core::Errors::ParsingError,
                      "#{self} -> #{line.inspect} does not match expectations for Attribute"
              end

              { matched[1] => plain_attribute_definition(matched[-2]) }
            end

            # Parses a line with attribute definitions into an `Occi::Core::AttributeDefinition` instance.
            #
            # @example
            #    plain_attribute_definition '{required immutable}'
            #       # => Occi::Core::AttributeDefinition
            #
            # @param line [String] line with plain text attribute definition(s)
            # @return [Occi::Core::AttributeDefinition] constructed instance
            def plain_attribute_definition(line)
              attr_def = Occi::Core::AttributeDefinition.new
              return attr_def if line.blank?

              attr_def.required! if line.include?('required')
              attr_def.immutable! if line.include?('immutable')

              attr_def
            end

            # Separates category identifiers from a single-line notation to an
            # array.
            #
            # @example
            #    plain_identifiers 'http://l/b/c#a http://a/a/b#r' # => [...]
            #
            # @param line [String] line with space-separated category identifiers
            # @return [Array] list of separated category identifiers
            def plain_identifiers(line)
              line.split.map(&:strip)
            end

            # Constructs an instance of `parsed[:class]` with given arguments.
            # All classes must be located in the `Occi::Core` namespace.
            #
            # @param parsed [Hash] arguments for instance construction
            # @return [Object] constructed instance
            def construct_instance(parsed)
              all = {
                term: parsed[:term], schema: parsed[:scheme], title: parsed[:title],
                attributes: parsed[:attributes] ? parsed[:attributes] : {}
              }

              klass = parsed[:class].capitalize
              klass = Occi::Core.const_get(klass)
              all[:location] = parsed[:location] if klass.instance_methods.include?(:location)

              klass.new(all)
            end

            # @param mixin [Occi::Core::Mixin] mixin instance needing applicability dereferencing
            # @param derefd [Array] list of all available category instances
            # @param parsed_rel [Array] textual representations of needed applicability targets
            def lookup_applies_references!(mixin, derefd, parsed_rel)
              return if parsed_rel.blank? || parsed_rel.count == 1 # only depends here
              parsed_rel.drop(1).each { |kind| mixin.applies << first_or_die(derefd, kind) }
            end

            # @param mixin [Occi::Core::Mixin] mixin instance needing dependency dereferencing
            # @param derefd [Array] list of all available category instances
            # @param parsed_rel [Array] textual representations of needed dependencies
            def lookup_depends_references!(mixin, derefd, parsed_rel)
              return if parsed_rel.blank?
              mixin.depends << first_or_die(derefd, parsed_rel.first)
            end

            # @param md [MatchData] `MatchData` instance to be converted
            # @return [Hash] converted hash
            def matchdata_to_hash(md)
              hash = {}
              md.names.each { |group| md[group] && hash[group.to_sym] = md[group] }
              hash
            end

            private :lookup_applies_references!, :lookup_depends_references!
          end
        end
      end
    end
  end
end
