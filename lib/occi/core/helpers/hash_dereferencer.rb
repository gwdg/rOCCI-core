module Occi
  module Core
    module Helpers
      # Introduces hash dereferencing capabilities to `Hash`. This allowes
      # hash instances containing `Occi::Core::Category` sub-types by
      # identifier and `Occi::Core::AttributeDefinition` instances by name to be
      # converted into proper objects.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module HashDereferencer
        # Replaces all references to existing categories with actual instances from
        # from the given model. Similar processing is done on attribute definitions
        # referenced by attribute names.
        #
        # @param klass [Class] klass serialized in this hash
        # @param model [Occi::Core::Model] model instance for dereferencing (category look-up)
        # @param attribute_definitions [Hash] hash with known attribute definitions for dereferencing
        # @return [Integer] number of changes made when dereferencing
        def dereference_with!(klass, model, attribute_definitions)
          unless model && attribute_definitions
            raise 'Both `model` and `attribute_definitions` are ' \
                  'required for dereferencing'
          end

          send(
            "dereference_#{klass.to_s.demodulize.downcase}_with!",
            model, attribute_definitions
          )
        end

        # Replaces all references to existing categories with actual instances from
        # from the given model. Similar processing is done on attribute definitions
        # referenced by attribute names.
        #
        # @param model [Occi::Core::Model] model instance for dereferencing (category look-up)
        # @param attribute_definitions [Hash] hash with known attribute definitions for dereferencing
        # @return [Integer] number of changes made when dereferencing
        def dereference_category_with!(model, attribute_definitions)
          changed = 0

          unless self[:actions].blank?
            self[:actions].map! { |action| dereference_via_model(action, model) }
            changed += self[:actions].count
          end
          changed += dereference_attribute_definitions_with!(attribute_definitions)

          changed
        end

        # Replaces all name-only references to existing attribute definitions with actual instances from
        # from the given hash.
        #
        # @param attribute_definitions [Hash] hash with known attribute definitions for dereferencing
        # @return [Integer] number of changes made when dereferencing
        def dereference_attribute_definitions_with!(attribute_definitions)
          return 0 if self[:attributes].blank?

          new_attributes = {}
          self[:attributes].each do |attribute|
            new_attributes[attribute] = dereference_via_hash(attribute, attribute_definitions)
          end
          self[:attributes] = new_attributes

          self[:attributes].count
        end

        # Replaces all references to existing categories with actual instances from
        # from the given model. Similar processing is done on attribute definitions
        # referenced by attribute names.
        #
        # @param model [Occi::Core::Model] model instance for dereferencing (category look-up)
        # @param attribute_definitions [Hash] hash with known attribute definitions for dereferencing
        # @return [Integer] number of changes made when dereferencing
        def dereference_kind_with!(model, attribute_definitions)
          changed = 0

          if self[:parent]
            self[:parent] = dereference_via_model(self[:parent], model)
            changed += 1
          end
          changed += dereference_category_with!(model, attribute_definitions)

          changed
        end

        # Replaces all hashes with attribute definitions with valid instnaces of
        # `Occi::Core::AttributeDefinition`.
        #
        # @param model [Occi::Core::Model] model instance for dereferencing (category look-up)
        # @param attribute_definitions [Hash] hash with known attribute definitions for dereferencing
        # @return [Integer] number of changes made when dereferencing
        def dereference_action_with!(_model, _attribute_definitions)
          return 0 if self[:attributes].blank?
          # TODO: handle attributes referenced by name only
          self[:attributes].each_pair do |key, val|
            self[:attributes][key] = Occi::Core::AttributeDefinition.new(val.symbolize_keys)
          end
          self[:attributes].count
        end

        # Replaces all references to existing categories with actual instances from
        # from the given model. Similar processing is done on attribute definitions
        # referenced by attribute names.
        #
        # @param model [Occi::Core::Model] model instance for dereferencing (category look-up)
        # @param attribute_definitions [Hash] hash with known attribute definitions for dereferencing
        # @return [Integer] number of changes made when dereferencing
        def dereference_mixin_with!(model, attribute_definitions)
          changed = 0

          %i[depends applies].each do |symbol|
            unless self[symbol].blank?
              self[symbol].map! { |elm| dereference_via_model(elm, model) }
              changed += self[symbol].count
            end
          end
          changed += dereference_category_with!(model, attribute_definitions)

          changed
        end

        # Looks up the given category in the model. Raises error if no
        # such category is found.
        #
        # @param identifier [String] category identifier
        # @param model [Occi::Core::Model] model instance for dereferencing (category look-up)
        # @return [Occi::Core::Category] instance located in the model
        def dereference_via_model(identifier, model)
          model.find_by_identifier!(identifier)
        end

        # Looks up the given attribute definition in the hash. Raises error if no
        # such attribute definition is found.
        #
        # @param identifier [String] attribute identifier (name)
        # @param hash [Hash] hash with known attribute definitions for dereferencing
        # @return [Occi::Core::AttributeDefinition] definition located in the hash
        def dereference_via_hash(identifier, hash)
          raise "Attribute definition #{identifier.inspect} not found in the hash" unless hash[identifier]
          hash[identifier]
        end

        private :dereference_via_hash, :dereference_via_model
      end
    end
  end
end
