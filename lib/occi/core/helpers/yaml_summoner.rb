module Occi
  module Core
    module Helpers
      # Introduces YAML parsing capabilities to every receiver
      # class.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module YamlSummoner
        # Reads the provided YAML file and passes its content as `args` to the
        # constructor of the class. YAML file is expected to provide all the
        # necessary information (depending on the class in question) in the
        # required form (appropriate types and structures). Dereferencing will
        # will be automatically attempted on suitable classes, this requires
        # `model` and `attribute_definitions` to be provided.
        #
        # @example
        #    Occi::Core::AttributeDefinition.from_yaml 'my_def.yml'
        #      # => #<Occi::Core::AttributeDefinition>
        #
        # @param path [String] path to a YAML File
        # @param model [Occi::Core::Model] model instance for dereferencing (category look-up)
        # @param attribute_definitions [Hash] hash with known attribute definitions for dereferencing
        # @return [Object] instance of receiver class
        def from_yaml(path, model = nil, attribute_definitions = nil)
          raise 'This method cannot be invoked on instances' unless is_a? Class
          allowed_classes = defined?(self::ALLOWED_YAML_CLASSES) ? self::ALLOWED_YAML_CLASSES : []

          object_args = YAML.safe_load(File.read(path), allowed_classes)
          object_args.symbolize_keys!
          object_args.dereference_with!(self, model, attribute_definitions) if needs_dereferencing?
          new object_args
        end

        # Identifies classes suitable for dereferencing.
        #
        # @return [TrueClass] if needs dereferencing
        # @return [FalseClass] if does not need dereferencing
        def needs_dereferencing?
          ancestors.include? Occi::Core::Category
        end
      end
    end
  end
end
