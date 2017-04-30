module Occi
  module Core
    module Renderers
      module Json
        # Implements methods common to all JSON-based renderers. This class
        # is not meant to be used directly, only as a parent to other type-specific
        # rendering classes.
        #
        # @attr object [Object] instance to be rendered
        # @attr options [Hash] additional rendering options
        #
        # @author Boris Parak <parak@cesnet.cz
        class Base
          include Yell::Loggable

          attr_accessor :object, :options

          # Shortcuts to interesting object attributes, always prefixed with `object_`
          DELEGATED = %i[
            respond_to? send id title source target summary kind parent action
            attributes actions mixins depends applies links rel empty? resources
            links action_instances
          ].freeze
          delegate(*DELEGATED, to: :object, prefix: true)

          # Constructs a renderer instance for the given
          # object.
          #
          # @param object [Object] instance to be rendered
          # @param options [Hash] additional options
          def initialize(object, options)
            @object = object
            @options = options
          end

          # Renders the given object to `JSON`.
          #
          # @return [String] object rendering as JSON
          def render
            render_hash.to_json
          end
        end
      end
    end
  end
end
