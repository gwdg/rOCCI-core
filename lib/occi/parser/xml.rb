module Occi
  module Parser
    module Xml
      # @param [String] string
      # @return [Occi::Collection]
      def self.collection(string)

        begin
          parsed_xml = Nokogiri::XML(string) { |config| config.strict.nonet }
        rescue Nokogiri::XML::SyntaxError => perr
          Occi::Log.error "[#{self}] Failed to parse XML input: #{perr.message}"
          raise Occi::Errors::ParserInputError, perr.message
        end

        hash = Hashie::Mash.new(Hash.from_xml(parsed_xml))
        Occi::Collection.new(hash)
      end
    end
  end
end