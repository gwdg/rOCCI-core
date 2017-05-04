module Occi
  module Core
    module Renderers
      # Contains all text-related classes and modules. This
      # module houses functionality transforming various internal
      # instances to a basic text-based rendering. In most
      # cases, it is not intended to be called explicitly. Its
      # instrumentation will be used automatically by selected
      # instances when calling `render` or `to_text`/`to_headers`.
      #
      # This is also the place where additional supported instance types
      # should be added. Please, refer to internal documentation
      # for details on how to add a new instance type.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module Text; end
    end
  end
end

# Load class-specific rendering primitives
Dir[File.join(File.dirname(__FILE__), 'text', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi
  module Core
    module Renderers
      # Implementes components necessary to render all required instance types
      # to `text` or `text`-like format. Currently supported instance types
      # can be queried via `::known_types`. Actual serialization happens in
      # type-specific serializer classes which can be found in `Occi::Core::Renderers::Text`.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class TextRenderer < BaseRenderer
        # Supported formats
        TEXT_FORMATS = %w[text text_plain text_occi headers].freeze

        class << self
          # Indicates whether this class is a renderer candidate.
          #
          # @return [TrueClass, FalseClass] renderer flag
          def renderer?
            true
          end

          # Returns a list of formats supported by this renderer.
          # Formats are compliant with method naming restrictions
          # and String-like.
          #
          # @return [Array] list of formats
          def formats
            TEXT_FORMATS
          end

          # Returns a frozen Hash providing mapping information between
          # supported types and supported serializers.
          #
          # @return [Array] list of known type->serializer mappings
          def known
            {
              'Occi::Core::Category'       => Occi::Core::Renderers::Text::Category,
              'Occi::Core::ActionInstance' => Occi::Core::Renderers::Text::ActionInstance,
              'Occi::Core::Collection'     => Occi::Core::Renderers::Text::Collection,
              'Occi::Core::Model'          => Occi::Core::Renderers::Text::Model,
              'Occi::Core::Resource'       => Occi::Core::Renderers::Text::Resource,
              'Occi::Core::Link'           => Occi::Core::Renderers::Text::Link
            }
          end
        end
      end
    end
  end
end
