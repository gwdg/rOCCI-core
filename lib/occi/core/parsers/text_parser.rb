module Occi
  module Core
    module Parsers
      # Contains all text-related classes and modules. This
      # module houses functionality transforming various internal
      # instances from basic text-based rendering.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module Text; end
    end
  end
end

# Load class-specific parsing primitives
Dir[File.join(File.dirname(__FILE__), 'text', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi
  module Core
    module Parsers
      # Implementes components necessary to parse all required instance types
      # from `text` or `text`-like format.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class TextParser
        include Yell::Loggable
      end
    end
  end
end
