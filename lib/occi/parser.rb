Dir[File.join(File.dirname(__FILE__), 'parser', '*.rb')].each { |file| require file.gsub('.rb', '') }

module Occi
  module Parser

    class << self

      # Parses an OCCI message and extracts OCCI relevant information
      # @param [String] media_type the media type of the OCCI message
      # @param [String] body the body of the OCCI message
      # @param [true, false] category for text/plain and text/occi media types information e.g. from the HTTP request location is needed to determine if the OCCI message includes a category or an entity
      # @param [Occi::Core::Resource,Occi::Core::Link] entity_type entity type to use for parsing of text plain entities
      # @param [Hash] header optional header of the OCCI message
      # @return [Occi::Collection] list consisting of an array of locations and the OCCI object collection
      def parse(media_type, body, category=false, entity_type=Occi::Core::Resource, header={})
        Occi::Log.debug '### Parsing request data to OCCI Collection ###'
        collection = Occi::Collection.new

        # remove the HTTP_ prefix if present
        header = Hash[header.map { |k, v| [k.gsub('HTTP_', '').upcase, v] }]
        Occi::Log.debug "### Parsing headers: #{header.inspect}"

        if category
          Occi::Log.debug '### Parsing categories from headers'
          collection = Occi::Parser::Text.categories(header.map { |k, v| v.to_s.split(',').collect { |w| "#{k}: #{w}" } }.flatten)
        else
          if entity_type == Occi::Core::Resource
            Occi::Log.debug '### Parsing a resource from headers'
            collection = Occi::Parser::Text.resource(header.map { |k, v| v.to_s.split(',').collect { |w| "#{k}: #{w}" } }.flatten)
          elsif entity_type == Occi::Core::Link
            Occi::Log.debug '### Parsing a link from headers'
            collection = Occi::Parser::Text.link(header.map { |k, v| v.to_s.split(',').collect { |w| "#{k}: #{w}" } }.flatten)
          else
            raise Occi::Errors::ParserTypeError, "Entity type #{entity_type} not supported"
          end
        end

        Occi::Log.debug "### Parsing #{media_type} from body"
        case media_type
        when 'text/uri-list'
          nil
        when 'text/occi'
          nil
        when 'text/plain', nil
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

      def locations(media_type, body, header)
        Occi::Log.debug "### Parsing locations from request headers: #{header.inspect}"
        locations = Occi::Parser::Text.locations header.map { |k, v| v.to_s.split(',').collect { |w| "#{k}: #{w}" } }.flatten
        locations << header['Location'] if header['Location'] && header['Location'].any?

        Occi::Log.debug "### Parsing #{media_type} locations from body"
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

    end

  end
end
