module Occi
  module Core
    module Parsers
      module Text
        # Static parsing class responsible for extracting categories from plain text.
        # Class supports 'text/plain' via `plain`. No other formats are supported.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Category
          # Regexp constants
          CATEGORY_REGEXP  = /#{Constants::REGEXP_CATEGORY}/
          ATTRIBUTE_REGEXP = /#{Constants::REGEXP_ATTRIBUTE_DEF}/

          class << self
            # TODO: docs
            #
            # @param lines [Array]
            # @return [Array]
            def plain(lines)
              cats = lines.map { |line| plain_category(line) }.compact
              dereference_identifiers cats
            end

            # TODO: docs
            def plain_category(line)
              matched = line.match(CATEGORY_REGEXP)
              unless matched
                raise Occi::Core::Errors::ParsingError,
                      "#{self} -> #{line.inspect} does not match expectations for Category"
              end

              cat = matchdata_to_hash(matched)
              cat[:attributes] = plain_attributes(cat[:attributes]) if cat[:attributes]
              cat[:rel] = plain_identifiers(cat[:rel]) if cat[:rel]
              cat[:actions] = plain_identifiers(cat[:actions]) if cat[:actions]
              cat
            end

            # TODO: docs
            def plain_attributes(line)
              # TODO: find a better approach to fixing split
              line.gsub!(/\{(immutable|required)\s+(required|immutable)\}/, '{\1_\2}')

              attributes = {}
              line.split.each { |attribute| attributes.merge! plain_attribute(attribute) }

              attributes
            end

            # TODO: docs
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

            # TODO: docs
            def plain_attribute_definition(line)
              attr_def = Occi::Core::AttributeDefinition.new
              return attr_def if line.blank?

              attr_def.required! if line.include?('required')
              attr_def.immutable! if line.include?('immutable')

              attr_def
            end

            # TODO: docs
            def plain_identifiers(line)
              line.split.map(&:strip)
            end

            # TODO: docs
            def dereference_identifiers(parsed)
              derefd = parsed.map { |cat| construct_instance(cat) }
              derefd.each do |cat|
                next if cat.is_a?(Occi::Core::Action) # nothing to do here
                lookup_references!(cat, derefd, parsed)
              end
              derefd
            end

            # TODO: docs
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

            # @param cat [Occi::Core::Mixin, Occi::Core::Kind]
            # @param derefd [Array]
            # @param parsed_actions [Array]
            def lookup_action_references!(cat, derefd, parsed_actions)
              return if parsed_actions.blank?
              parsed_actions.each { |action| cat.actions << find_first_or_die(derefd, action) }
            end

            # @param kind [Occi::Core::Kind]
            # @param derefd [Array]
            # @param parsed_rel [Array]
            def lookup_parent_references!(kind, derefd, parsed_rel)
              return if parsed_rel.blank?
              if parsed_rel.count > 1
                raise Occi::Core::Errors::ParsingError,
                      "#{self} -> Kind #{kind} with multiple parents #{parsed_rel.inspect}"
              end

              kind.parent = find_first_or_die(derefd, parsed_rel.first)
              kind.send(:load_parent_attributes!) # this is safe because there was no previous parent!
            end

            # @param mixin [Occi::Core::Mixin]
            # @param derefd [Array]
            # @param parsed_rel [Array]
            def lookup_applies_references!(mixin, derefd, parsed_rel)
              return if parsed_rel.blank? || parsed_rel.count == 1 # only depends here
              parsed_rel.drop.each { |kind| mixin.applies << find_first_or_die(derefd, kind) }
            end

            # @param mixin [Occi::Core::Mixin]
            # @param derefd [Array]
            # @param parsed_rel [Array]
            def lookup_depends_references!(mixin, derefd, parsed_rel)
              return if parsed_rel.blank?
              mixin.depends << find_first_or_die(derefd, parsed_rel.first)
            end

            # @param md [MatchData]
            # @return [Hash]
            def matchdata_to_hash(md)
              hash = {}
              md.names.each { |group| md[group] && hash[group.to_sym] = md[group] }
              hash
            end

            # @param where [Enumerable]
            # @param what [Object]
            # @return [Object]
            def find_first_or_die(where, what)
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
