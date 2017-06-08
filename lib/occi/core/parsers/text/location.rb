module Occi
  module Core
    module Parsers
      module Text
        # Static parsing class responsible for extracting URI-like locations from plain text.
        # Class supports both 'text/uri-list' and 'text/plain' via `uri_list` and `plain` respectively.
        #
        # @author Boris Parak <parak@cesnet.cz>
        class Location
          include Yell::Loggable
          include Helpers::ErrorHandler

          class << self
            # Shortcuts to interesting methods on logger
            DELEGATED = %i[debug? info? warn? error? fatal?].freeze
            delegate(*DELEGATED, to: :logger, prefix: true)

            # Parses text/plain OCCI locations into `URI` instances suitable for futher processing.
            # Every location line is expected to begin with 'X-OCCI-Location'.
            #
            # @param lines [Array] list of lines to parse
            # @return [Array] list of locations (URIs)
            def plain(lines)
              regexp = Regexp.new(Constants::REGEXP_LOCATION)

              locations = lines.map do |line|
                next if line.blank?
                logger.debug "Parsing location from line #{line.inspect}" if logger_debug?

                matched = line.match(regexp)
                unless matched
                  raise Occi::Core::Errors::ParsingError, "#{line.inspect} does not match 'X-OCCI-Location: URI'"
                end
                handle(Occi::Core::Errors::ParsingError) { URI.parse(matched[:location].strip) }
              end

              locations.compact
            end

            # Parses text/uri-list lines into `URI` instances suitable for futher processing.
            # Lines starting with '#' are ommited, as per https://tools.ietf.org/html/rfc2483#section-5
            #
            # @param lines [Array] list of lines to parse
            # @return [Array] list of locations (URIs)
            def uri_list(lines)
              uris = lines.map do |line|
                next if line.blank? || line.start_with?('#')
                logger.debug "Parsing location from line #{line.inspect}" if logger_debug?

                handle(Occi::Core::Errors::ParsingError) { URI.parse(line.strip) }
              end

              uris.compact
            end
          end
        end
      end
    end
  end
end
