module Occi
  module Core
    # Base loader for static categories defined in the OCCI Core Standard
    # published by OGF's OCCI WG. This warehouse is meant to be used as a
    # quick bootstrap tools for `Occi::Core::Model` instances.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Warehouse
      include Yell::Loggable

      # YAML DIR constants
      BASE    = 'warehouse'.freeze
      KINDS   = 'kinds'.freeze
      ACTIONS = 'actions'.freeze
      MIXINS  = 'mixins'.freeze
      ATTRIBS = 'attributes'.freeze

      # YAML file pattern
      FILE_SUFFIX = '.yml'.freeze
      YAML_GLOB   = "*#{FILE_SUFFIX}".freeze

      class << self
        # Bootstraps the given model instance with pre-defined category
        # instances.
        #
        # @example
        #    model = Occi::Core::Model.new
        #    Occi::Core::Warehouse.bootstrap! model
        #
        # @param model [Occi::Core::Model] model to be bootstrapped
        def bootstrap!(model)
          actions! model
          kinds! model
          mixins! model
          nil # TODO: return something sensible
        end

        protected

        # :nodoc:
        def whereami
          File.expand_path(File.dirname(__FILE__))
        end

        # :nodoc:
        def warehouse_path
          File.join(whereami, BASE)
        end

        # :nodoc:
        def kinds_path
          File.join(warehouse_path, KINDS)
        end

        # :nodoc:
        def actions_path
          File.join(warehouse_path, ACTIONS)
        end

        # :nodoc:
        def mixins_path
          File.join(warehouse_path, MIXINS)
        end

        # :nodoc:
        def kinds!(model)
          attribute_definitions = attribute_definitions_for(kinds_path)
          yamls_in(kinds_path).each do |file|
            model << Occi::Core::Kind.from_yaml(file, model, attribute_definitions)
          end
        end

        # :nodoc:
        def mixins!(model)
          attribute_definitions = attribute_definitions_for(mixins_path)
          yamls_in(mixins_path).each do |file|
            model << Occi::Core::Mixin.from_yaml(file, model, attribute_definitions)
          end
        end

        # :nodoc:
        def actions!(model)
          # TODO: work with separate attribute definitions
          attribute_definitions = {}
          yamls_in(actions_path).each do |file|
            model << Occi::Core::Action.from_yaml(file, model, attribute_definitions)
          end
        end

        # :nodoc:
        def attribute_definitions_for(categories_path)
          attribute_definitions = {}

          attr_defs_path = File.join(categories_path, ATTRIBS)
          yamls_in(attr_defs_path).each do |file|
            name = attribute_name_from(file)
            attribute_definitions[name] = Occi::Core::AttributeDefinition.from_yaml(file)
          end

          attribute_definitions
        end

        # :nodoc:
        def attribute_name_from(path)
          path.split(File::SEPARATOR).last.gsub(FILE_SUFFIX, '')
        end

        # :nodoc:
        def yamls_in(path)
          Dir[File.join(path, YAML_GLOB)].sort
        end
      end
    end
  end
end
