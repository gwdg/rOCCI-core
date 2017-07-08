require 'occi/core/renderers/text/base'

module Occi
  module Core
    module Renderers
      module Text
        # Implements routines required to render `Occi::Core::Locations` and
        # its subclasses to a text-based representation. Supports rendering
        # to plain and header-like formats.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Locations < Base
          # Location key constants
          LOCATION_KEY_PLAIN = 'X-OCCI-Location'.freeze
          LOCATION_KEY_HEADERS = 'Location'.freeze

          # Renders `object` into plain text and returns the result
          # as `String`.
          #
          # @return [String] textual representation of Object
          def render_plain
            locs = object.map { |loc| "#{LOCATION_KEY_PLAIN}: #{loc}" }
            locs.join "\n"
          end

          # Renders `object` into text for headers and returns the result
          # as `Hash`.
          #
          # @return [Hash] textual representation of Object for headers
          def render_headers
            { LOCATION_KEY_HEADERS => object.map(&:to_s) }
          end
        end
      end
    end
  end
end
