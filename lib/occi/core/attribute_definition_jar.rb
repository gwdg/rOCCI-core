module Occi
  module Core
    # TODO: Docs
    #
    # @author Boris Parak <parak@cesnet.cz>
    class AttributeDefinitionJar
      include Yell::Loggable
      include Helpers::ArgumentValidator

      attr_accessor :paths, :attribute_definitions

      #
      WHEREAMI = File.expand_path(File.dirname(__FILE__)).freeze
      JAR_DIR = 'attribute_definition_jar'.freeze
      FILE_SUFFIX = '.yml'.freeze
      ALLOWED_YAML_CLASSES = [String, Regexp].freeze

      #
      DEFAULT_PATH = File.join(WHEREAMI, JAR_DIR).freeze
      DEFAULT_PATHS = [DEFAULT_PATH].freeze

      #
      def initialize(args = {})
        pre_initialize(args)
        default_args! args

        @paths = args.fetch(:paths)
        @attribute_definitions = args.fetch(:attribute_definitions)

        post_initialize(args)
      end

      #
      def get(attribute_name)
        attribute_definitions[attribute_name]
      end

      #
      def get!(attribute_name)
        unless attribute_definitions.key?(attribute_name)
          raise "#{attribute_name.inspect} does not exists in #{self}"
        end
        get attribute_name
      end

      #
      def put(attribute_name, attribute_definition)
        attribute_definitions[attribute_name] = attribute_definition
      end

      #
      def put!(attribute_name, attribute_definition)
        if attribute_definitions.key?(attribute_name)
          raise "#{attribute_name.inspect} already exists in #{self}"
        end
        put attribute_name, attribute_definition
      end

      #
      def attribute_names
        attribute_definitions.keys
      end

      #
      def reload!
        self.attribute_definitions = {} unless attribute_definitions.empty?

        files = paths.reduce([]) { |prod, path| prod.concat Dir[File.join(path, "*#{FILE_SUFFIX}")] }
        files.each { |path| put! attribute_name_from(path), attribute_definition_from(path) }
      end

      #
      def self.default_paths
        DEFAULT_PATHS
      end

      protected

      # :nodoc:
      def attribute_name_from(path)
        path.split(File::SEPARATOR).last.gsub(FILE_SUFFIX, '')
      end

      # :nodoc:
      def attribute_definition_from(path)
        attr_def = YAML.safe_load(File.read(path), ALLOWED_YAML_CLASSES)
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
        reload!
      end
    end
  end
end
