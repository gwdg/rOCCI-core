module Occi
  module Core
    module Renderers
      # TODO
      #
      # @author Boris Parak <parak@cesnet.cz>
      class TextRenderer
        # Supported formats
        TEXT_FORMATS = %w(text text_plain text_occi headers).freeze

        class << self
          # Indicates this class is a renderer candidate.
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

          # Renders the given `object` into Text. Specific text-based
          # formatting is chosen based on the `options[:format]` value.
          #
          # @param object [Object] instance to be rendered
          # @param options [Hash] additional rendering options
          # @option options [String] :format (nil) rendering (sub)type
          # @return [String] object rendering
          def render(object, options)
            object.inspect # TODO: impl
          end
        end
      end
    end
  end
end
