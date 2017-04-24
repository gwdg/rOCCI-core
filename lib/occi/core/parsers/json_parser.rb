module Occi
  module Core
    module Parsers
      # Contains all JSON-related classes and modules. This
      # module houses functionality transforming various internal
      # instances from basic JSON rendering.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module Json; end
    end
  end
end

# Load class-specific parsing primitives
Dir[File.join(File.dirname(__FILE__), 'json', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi
  module Core
    module Parsers
      # Implementes components necessary to parse all required instance types
      # from `JSON` or `JSON`-like format.
      #
      # @attr model [Occi::Core::Model, Occi::Infrastructure::Model] model to use as a primary reference point
      # @attr media_type [String] type of content to parse
      #
      # @author Boris Parak <parak@cesnet.cz>
      class JsonParser
        include Yell::Loggable
        include Helpers::ArgumentValidator
        include Helpers::ErrorHandler

        # Media type constants
        MEDIA_TYPES = %w[application/occi+json application/json].freeze

        attr_accessor :model, :media_type
      end
    end
  end
end
