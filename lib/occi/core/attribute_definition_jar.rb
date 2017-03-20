module Occi
  module Core
    # Provides a wrapper for common attribute definitions. These definitions
    # are pre-loaded and ready to be used. By default, jars contain definitions
    # for attributes specified in the OCCI standard. Attribute definitions are
    # read from provided paths. Each path should point to a directory containing
    # YAML files containing attribute definitions compliant with `Occi::Core::AttributeDefinition`
    # arguments. Files must follow this naming syntax:
    #   <attribute.name.here>.yml
    # and contain only one attribute definition per file.
    #
    # @attr paths [Array] String paths to directories containing YAML files with definitions
    # @attr attribute_definitions [Hash] Pre-loaded definitions
    #
    # @author Boris Parak <parak@cesnet.cz>
    class AttributeDefinitionJar
      include Yell::Loggable
      include Helpers::ArgumentValidator

      attr_accessor :paths, :attribute_definitions

      # Base for default jar DIR look-up
      WHEREAMI = File.expand_path(File.dirname(__FILE__)).freeze
      # Default jar DIR
      JAR_DIR = 'attribute_definition_jar'.freeze
      # Default suffix for YAML files
      FILE_SUFFIX = '.yml'.freeze
      # Allowed classes for YAML parser
      ALLOWED_YAML_CLASSES = [String, Regexp, Occi::Core::Resource].freeze

      # Default path to jar DIR
      DEFAULT_PATH = File.join(WHEREAMI, JAR_DIR).freeze
      # Default paths for attribute definition look-up
      DEFAULT_PATHS = [DEFAULT_PATH].freeze

      # Constructs a jar instance with sensible defaults.
      #
      # @param args [Hash] arguments for jar creation
      # @option args [Array] :paths String paths to directories containing YAML files with definitions
      # @option args [Hash] :attribute_definitions Pre-loaded definitions
      def initialize(args = {})
        pre_initialize(args)
        default_args! args

        @paths = args.fetch(:paths)
        @attribute_definitions = args.fetch(:attribute_definitions)

        post_initialize(args)
      end

      # Retrieves given attribute from the jar. Returns `nil` for non-existent
      # attributes.
      #
      # @example
      #    get 'occi.core.id'   # => Occi::Core::AttributeDefinition
      #    get 'meh.what.maybe' # => nil
      #
      # @param attribute_name [String] name of the attribute to retrieve
      # @return [Occi::Core::AttributeDefinition] when definition found in jar
      # @return [NilClass] when definition not found in jar
      def get(attribute_name)
        attribute_definitions[attribute_name]
      end

      # Retrieves given attribute from the jar. Raises an error for non-existent
      # attributes.
      #
      # @example
      #    get! 'occi.core.id'   # => Occi::Core::AttributeDefinition
      #    get! 'meh.what.maybe' # => error
      #
      # @param attribute_name [String] name of the attribute to retrieve
      # @return [Occi::Core::AttributeDefinition] when definition found in jar
      def get!(attribute_name)
        unless attribute_definitions.key?(attribute_name)
          raise "#{attribute_name.inspect} does not exists in #{self}"
        end
        get attribute_name
      end

      # Adds given attribute definition to the jar. Existing definition will
      # be quietly over-written.
      #
      # @example
      #    attr_def = Occi::Core::AttributeDefinition.new
      #    put 'occi.core.id', attr_def
      #
      # @param attribute_name [String] name of the attribute
      # @param attribute_definition [Occi::Core::AttributeDefinition] attribute definition
      def put(attribute_name, attribute_definition)
        attribute_definitions[attribute_name] = attribute_definition
      end

      # Adds given attribute definition to the jar. Existing definition will
      # cause an error to be raised.
      #
      # @example
      #    attr_def = Occi::Core::AttributeDefinition.new
      #    put! 'occi.core.id', attr_def
      #
      # @param attribute_name [String] name of the attribute
      # @param attribute_definition [Occi::Core::AttributeDefinition] attribute definition
      def put!(attribute_name, attribute_definition)
        if attribute_definitions.key?(attribute_name)
          raise "#{attribute_name.inspect} already exists in #{self}"
        end
        put attribute_name, attribute_definition
      end

      # Returns a list of attribute names present in the jar.
      #
      # @return [Array] list of attribute names
      def attribute_names
        attribute_definitions.keys
      end

      # Checks for existence of a particular attribute in the jar. By name.
      #
      # @example
      #    include? 'occi.core.id' # => true
      #    include? 'meh.maybe.id' # => false
      #
      # @param attribute_name [String] name of the attribute
      # @return [TrueClass] if attribute is present
      # @return [FalseClass] if attribute is not present
      def include?(attribute_name)
        attribute_names.include? attribute_name
      end

      # Reloads the content of the jar from previously defined paths. This action
      # will drop all existing content.
      def reload!
        self.attribute_definitions = {} unless attribute_definitions.empty?

        files = paths.reduce([]) { |prod, path| prod.concat Dir[File.join(path, "*#{self.class::FILE_SUFFIX}")] }
        files.each { |path| put! attribute_name_from(path), attribute_definition_from(path) }
      end

      # Returns default paths used as sensible defaults when this class is instantiated
      # without arguments.
      #
      # @return [Array] list of paths
      def self.default_paths
        self::DEFAULT_PATHS
      end

      protected

      # :nodoc:
      def attribute_name_from(path)
        path.split(File::SEPARATOR).last.gsub(self.class::FILE_SUFFIX, '')
      end

      # :nodoc:
      def attribute_definition_from(path)
        attr_def = YAML.safe_load(File.read(path), self.class::ALLOWED_YAML_CLASSES)
        attr_def.symbolize_keys!
        Occi::Core::AttributeDefinition.new attr_def
      end

      # :nodoc:
      def sufficient_args!(args)
        return if args[:paths] && args[:attribute_definitions]
        raise Occi::Core::Errors::MandatoryArgumentError, '\'paths\' and \'attribute_definitions\' are mandatory ' \
              "arguments for #{self.class}"
      end

      # :nodoc:
      def defaults
        { paths: self.class.default_paths, attribute_definitions: {} }
      end

      # :nodoc:
      def pre_initialize(args); end

      # :nodoc:
      def post_initialize(_args)
        reload! if attribute_definitions.empty?
      end
    end
  end
end
