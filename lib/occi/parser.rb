Dir[File.join(File.dirname(__FILE__), 'parser', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi
  module Parser

    class << self

      OCCI_HEADERS = ['Category', 'Link', 'X-OCCI-Location', 'X-OCCI-Attribute', 'Location'].freeze

      # Parses an OCCI message and extracts OCCI relevant information
      # @param [String] media_type the media type of the OCCI message
      # @param [String] body the body of the OCCI message
      # @param [true, false] category for text/plain and text/occi media types information e.g. from the HTTP request location is needed to determine if the OCCI message includes a category or an entity
      # @param [Occi::Core::Resource,Occi::Core::Link] entity_type entity type to use for parsing of text plain entities
      # @param [Hash] header optional header of the OCCI message
      # @return [Occi::Collection] list consisting of an array of locations and the OCCI object collection
      def parse(media_type, body, category=false, entity_type=Occi::Core::Resource, header={})
        Occi::Log.debug "[#{self}] Parsing request data to OCCI Collection"
        header = headers_to_arys(header)

        Occi::Log.debug "[#{self}] Parsing headers: #{header.inspect}"
        collection = parse_headers(header, category, entity_type)

        Occi::Log.debug "[#{self}] Parsing #{media_type} from body"
        coll_body = parse_body(media_type, body, category, entity_type)
        collection.merge! coll_body if coll_body && !coll_body.empty?

        collection
      end

      def locations(media_type, body, header)
        header = headers_to_arys(header)

        Occi::Log.debug "[#{self}] Parsing locations from request headers: #{header.inspect}"
        locations = Occi::Parser::Text.locations(header)
        locations << header['Location'] if header['Location'] && header['Location'].any?

        Occi::Log.debug "[#{self}] Parsing #{media_type} locations from body"
        case media_type
        when 'text/uri-list'
          locations << body.split("\n")
        when 'text/plain', nil
          locations << Occi::Parser::Text.locations(body.split "\n")
        else
          nil
        end

        locations.flatten
      end

      private

      def parse_headers(header, category, entity_type)
        if category
          Occi::Log.debug "[#{self}] Parsing categories from headers"
          collection = Occi::Parser::Text.categories(header)
        else
          if entity_type == Occi::Core::Resource
            Occi::Log.debug "[#{self}] Parsing a resource from headers"
            collection = Occi::Parser::Text.resource(header)
          elsif entity_type == Occi::Core::Link
            Occi::Log.debug "[#{self}] Parsing a link from headers"
            collection = Occi::Parser::Text.link(header)
          else
            raise Occi::Errors::ParserTypeError, "Entity type '#{entity_type}' not supported"
          end
        end

        collection
      end

      def parse_body(media_type, body, category, entity_type)
        collection = Occi::Collection.new

        case media_type
        when 'text/uri-list'
          nil
        when 'text/occi'
          nil
        when 'text/plain', nil
          collection = parse_body_plain(body, category, entity_type)
        when 'application/occi+json', 'application/json'
          collection = Occi::Parser::Json.collection body
        when 'application/occi+xml', 'application/xml'
          collection = Occi::Parser::Xml.collection body
        when 'application/ovf', 'application/ovf+xml'
          collection = Occi::Parser::Ovf.collection body
        when 'application/ova'
          collection = Occi::Parser::Ova.collection body
        else
          raise Occi::Errors::ParserTypeError, "Content type #{media_type} not supported"
        end

        collection
      end

      def parse_body_plain(body, category, entity_type)
        if category
          collection = Occi::Parser::Text.categories body.split "\n"
        else
          if entity_type == Occi::Core::Resource
            collection = Occi::Parser::Text.resource body.split "\n"
          elsif entity_type == Occi::Core::Link
            collection = Occi::Parser::Text.link body.split "\n"
          else
            raise Occi::Errors::ParserTypeError, "Entity type #{entity_type} not supported"
          end
        end

        collection
      end

      def headers_to_arys(header)
        # remove the HTTP_ prefix if present and capitalize keys
        header = Hash[header.map { |k, v| [k.gsub('HTTP_', '').capitalize, v] }]
        header['X-OCCI-Location'] = header['X-occi-location'] if header['X-occi-location']
        header['X-OCCI-Attribute'] = header['X-occi-attribute'] if header['X-occi-attribute']

        header.delete_if { |k, v| v.blank? || !OCCI_HEADERS.include?(k) }

        header.map { |k, v| v.to_s.split(',').collect { |w| "#{k}: #{w}" } }.flatten
      end

    end

  end
end
