module Occi
  module Core
    module Renderers
      # Implementes components common to all rendereres. It is not intended for direct use.
      #
      # @abstract Not for direct use.
      # @author Boris Parak <parak@cesnet.cz>
      class BaseRenderer
        include Yell::Loggable

        class << self
          # Indicates whether this class is a renderer candidate.
          #
          # @return [TrueClass, FalseClass] renderer flag
          def renderer?
            false
          end

          # Returns a list of formats supported by this renderer.
          # Formats are compliant with method naming restrictions
          # and String-like.
          #
          # @return [Array] list of formats
          def formats
            []
          end

          # Renders the given `object` into a rendering in `options[:format]`.
          #
          # @param object [Object] instance to be rendered
          # @param options [Hash] additional rendering options
          # @option options [String] :format (nil) rendering (sub)type
          # @return [String] object rendering
          def render(object, options)
            logger.debug "#{self} rendering #{object.inspect} with #{options.inspect}"
            candidate = rendering_candidate(object)
            unless candidate
              raise Occi::Core::Errors::RenderingError, "#{object.class} cannot be " \
                    "rendered to #{options[:format]}"
            end

            known[candidate].new(object, options).render
          end

          # Returns the list of known (and supported) types for serialization.
          # Every element in the list is a string representing a fully
          # namespaced class name.
          #
          # @return [Array] list of known types
          def known_types
            known.keys
          end

          # Returns the list of known (and supported) serializer classes.
          # Every element in the list is a fully namespaced classes.
          #
          # @return [Array] list of known serializers
          def known_serializers
            known.values
          end

          # Returns a frozen Hash providing mapping information between
          # supported types and supported serializers.
          #
          # @return [Array] list of known type->serializer mappings
          def known
            {}
          end

          private

          # :nodoc:
          def rendering_candidate(object)
            object_ancestors = object.class.ancestors.collect(&:to_s)
            object_ancestors.detect { |klass| known_types.include?(klass) }
          end
        end
      end
    end
  end
end
