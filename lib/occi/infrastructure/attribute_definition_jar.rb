module Occi
  module Infrastructure
    # TODO: Docs
    #
    # @author Boris Parak <parak@cesnet.cz>
    class AttributeDefinitionJar < Occi::Core::AttributeDefinitionJar
      # Base for default jar DIR look-up
      WHEREAMI = File.expand_path(File.dirname(__FILE__)).freeze
      # Allowed classes for YAML parser
      ALLOWED_YAML_CLASSES = (
        Occi::Core::AttributeDefinitionJar::ALLOWED_YAML_CLASSES + [IPAddr, Integer, Float]
      ).freeze

      # Default path to jar DIR
      DEFAULT_PATH = File.join(WHEREAMI, JAR_DIR).freeze
      # Default paths for attribute definition look-up
      DEFAULT_PATHS = [Occi::Core::AttributeDefinitionJar::DEFAULT_PATH, DEFAULT_PATH].freeze
    end
  end
end
