module Occi
  module Core
    module Parsers
      module Json
        # Class responsible for validating JSON content before parsing. This should be called from
        # every parsing class.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Validator
          # Repository constants
          SCHEMA_DIR   = 'validator'.freeze
          SCHEMA_REPO  = File.join(File.expand_path(File.dirname(__FILE__)), SCHEMA_DIR)
          BASE_SCHEMAS = %i[occi-schema].freeze

          class << self
            # Validates given `json` text with the appropriate schema for `type`.
            # This method raises `Occi::Core::Errors::ParsingError` on failure.
            #
            # @param json [String] JSON text to validate
            # @param type [Symbol] schema selector
            # @raise [Occi::Core::Errors::ParsingError] on validation failure
            def validate!(json, type)
              JSON::Validator.schema_reader = JSON::Schema::Reader.new(accept_uri: false, accept_file: true)
              JSON::Validator.validate!(schema_for(type), json, json: true)
            rescue JSON::Schema::ValidationError => e
              raise Occi::Core::Errors::ParsingError, "#{self} -> #{e.message}", e
            end

            # :nodoc:
            def validate_model!(json)
              validate! json, :model
            end

            # :nodoc:
            def validate_resource!(json)
              validate! json, :resource
            end

            # :nodoc:
            def validate_link!(json)
              validate! json, :link
            end

            # :nodoc:
            def validate_action_instance!(json)
              validate! json, :'action-instance'
            end

            # :nodoc:
            def validate_entity_collection!(json)
              validate! json, :'entity-collection'
            end

            # :nodoc:
            def validate_link_collection!(json)
              validate! json, :'link-collection'
            end

            # :nodoc:
            def validate_resource_collection!(json)
              validate! json, :'resource-collection'
            end

            # :nodoc:
            def validate_mixin_collection!(json)
              validate! json, :'mixin-collection'
            end

            # :nodoc:
            def schema_for(type)
              if type.blank? || BASE_SCHEMAS.include?(type)
                raise Occi::Core::Errors::ParserError, "Schema type #{type.inspect} is not allowed"
              end
              File.join(SCHEMA_REPO, "#{type}.json")
            end
            private :schema_for
          end
        end
      end
    end
  end
end
