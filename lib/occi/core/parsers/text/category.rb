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

          # Regexp constants
          CATEGORY_REGEXP  = /#{Constants::REGEXP_CATEGORY}/
          ATTRIBUTE_REGEXP = /^#{Constants::REGEXP_ATTRIBUTE_DEF}$/

          class << self
            # Parses category lines into instances of subtypes of `Occi::Core::Category`. Internal references
            # between objects are converted from strings to actual objects.
            #
            # @param lines [Array] list of single-category lines
            # @return [Array] list of category instances
            def plain(lines)
              raw_categories = lines.map { |line| plain_category(line) }.compact
              instances = raw_categories.map { |cat| construct_instance(cat) }
              dereference_identifiers! instances, raw_categories
              instances
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

            # Dereferences cross-category references. Takes existing string
            # identifiers for actions, mixins, and kinds and replaces them
            # with actual instances.
            #
            # @param derefd [Array] list of instances needing dereferencing
            # @param parsed [Array] list of raw parsed categories (as hashes)
            # @return [Array] dereferenced list of instances
            def dereference_identifiers!(derefd, parsed)
              derefd.each do |cat|
                next if cat.is_a?(Occi::Core::Action) # nothing to do here
                lookup_references!(cat, derefd, parsed)
              end
              derefd
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
              all[:location] = parsed[:location] if klass.ancestors.include?(Occi::Core::Helpers::Locatable)

              klass.new(all)
            end

            # Looks up inter-category references and replaces them with existing objects.
            #
            # @param cat [Occi::Core::Mixin, Occi::Core::Kind] category to dereference
            # @param derefd [Array] list of known categories
            # @param parsed [Array] list of original parsed category structures
            def lookup_references!(cat, derefd, parsed)
              parsed_cat = parsed.detect { |pcat| "#{pcat[:scheme]}#{pcat[:term]}" == cat.identifier }

              lookup_action_references!(cat, derefd, parsed_cat[:actions])

              if cat.is_a?(Occi::Core::Mixin)
                lookup_depends_references!(cat, derefd, parsed_cat[:rel])
                lookup_applies_references!(cat, derefd, parsed_cat[:rel])
              else
                # only Occi::Core::Kind is left here
                lookup_parent_references!(cat, derefd, parsed_cat[:rel])
              end
            end

            # @param cat [Occi::Core::Mixin, Occi::Core::Kind] category instance needing action dereferencing
            # @param derefd [Array] list of all available category instances
            # @param parsed_actions [Array] textual representation of needed actions
            def lookup_action_references!(cat, derefd, parsed_actions)
              return if parsed_actions.blank?
              parsed_actions.each { |action| cat.actions << first_or_die(derefd, action) }
            end

            # @param kind [Occi::Core::Kind] kind instance needing parent dereferencing
            # @param derefd [Array] list of all available category instances
            # @param parsed_rel [Array] textual representation of needed parent(s)
            def lookup_parent_references!(kind, derefd, parsed_rel)
              return if parsed_rel.blank?
              if parsed_rel.count > 1
                raise Occi::Core::Errors::ParsingError,
                      "#{self} -> Kind #{kind} with multiple parents #{parsed_rel.inspect}"
              end

              kind.parent = first_or_die(derefd, parsed_rel.first)
              kind.send(:load_parent_attributes!) # this is safe because there was no previous parent!
            end

            # @param mixin [Occi::Core::Mixin] mixin instance needing applicability dereferencing
            # @param derefd [Array] list of all available category instances
            # @param parsed_rel [Array] textual representations of needed applicability targets
            def lookup_applies_references!(mixin, derefd, parsed_rel)
              return if parsed_rel.blank? || parsed_rel.count == 1 # only depends here
              parsed_rel.drop.each { |kind| mixin.applies << first_or_die(derefd, kind) }
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

            # @param where [Enumerable] list of items to look through, items must respond to `.identifier`
            # @param what [String] identifier of the desired item
            # @return [Object] desired item from `where`
            def first_or_die(where, what)
              found = where.detect { |elm| elm.identifier == what }
              unless found
                raise Occi::Core::Errors::ParsingError,
                      "#{self} -> Category #{what.to_s.inspect} referenced but not provided"
              end
              found
            end
          end
        end
      end
    end
  end
end
