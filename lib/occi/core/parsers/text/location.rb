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

          class << self
            # Parses text/plain OCCI locations into `URI` instances suitable for futher processing.
            # Every location line is expected to begin with 'X-OCCI-Location'.
            #
            # @param lines [Array] list of lines to parse
            # @return [Array] list of locations (URIs)
            def plain(lines)
              regexp = Regexp.new(Constants::REGEXP_LOCATION)
              lines.map do |line|
                next if line.blank?
                matched = line.match(regexp)
                unless matched
                  raise Occi::Core::Errors::ParsingError,
                        "#{self} -> #{line.inspect} does not match 'X-OCCI-Location: URI'"
                end
                URI.parse matched[:location].strip
              end.compact
            end

            # Parses text/uri-list lines into `URI` instances suitable for futher processing.
            # Lines starting with '#' are ommited, as per https://tools.ietf.org/html/rfc2483#section-5
            #
            # @param lines [Array] list of lines to parse
            # @return [Array] list of locations (URIs)
            def uri_list(lines)
              lines.map do |line|
                next if line.start_with?('#') || line.blank?
                URI.parse line.strip
              end.compact
            end
          end
        end
      end
    end
  end
end
