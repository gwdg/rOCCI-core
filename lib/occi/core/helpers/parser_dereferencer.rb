module Occi
  module Core
    module Helpers
      # Introduces dereferencing capabilities to various parsers. This allowes
      # parsers to convert `Occi::Core::Category` sub-types from identifier into proper objects.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module ParserDereferencer
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

        # Looks up inter-category references and replaces them with existing objects.
        #
        # @param cat [Occi::Core::Mixin, Occi::Core::Kind] category to dereference
        # @param derefd [Array] list of known categories
        # @param parsed [Array] list of original parsed category structures
        def lookup_references!(cat, derefd, parsed)
          parsed_cat = parsed.detect { |pcat| "#{pcat[:scheme]}#{pcat[:term]}" == cat.identifier }
          raise Occi::Core::Errors::ParsingError, "#{self} -> #{cat.identifier} not in the model" unless parsed_cat
          lookup_action_references!(cat, derefd, parsed_cat[:actions])

          if cat.is_a?(Occi::Core::Mixin)
            lookup_depends_references!(cat, derefd, parsed_cat[self::DEPENDS_KEY])
            lookup_applies_references!(cat, derefd, parsed_cat[self::APPLIES_KEY])
          else
            # only Occi::Core::Kind is left here
            lookup_parent_references!(cat, derefd, parsed_cat[self::PARENT_KEY])
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
          return if parsed_rel.blank? || kind.parent.is_a?(Occi::Core::Kind)
          if parsed_rel.is_a?(Enumerable)
            if parsed_rel.count > 1
              raise Occi::Core::Errors::ParsingError,
                    "#{self} -> Kind #{kind} with multiple parents #{parsed_rel.inspect}"
            end
            parsed_rel = parsed_rel.first
          end

          kind.parent = first_or_die(derefd, parsed_rel)
          kind.send(:load_parent_attributes!) # this is safe because there was no previous parent!
        end

        # @param mixin [Occi::Core::Mixin] mixin instance needing applicability dereferencing
        # @param derefd [Array] list of all available category instances
        # @param parsed_rel [Array] textual representations of needed applicability targets
        def lookup_applies_references!(_mixin, _derefd, _parsed_rel)
          raise Occi::Core::Errors::ParserError, 'Must be implemented in the parser class'
        end

        # @param mixin [Occi::Core::Mixin] mixin instance needing dependency dereferencing
        # @param derefd [Array] list of all available category instances
        # @param parsed_rel [Array] textual representations of needed dependencies
        def lookup_depends_references!(_mixin, _derefd, _parsed_rel)
          raise Occi::Core::Errors::ParserError, 'Must be implemented in the parser class'
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
