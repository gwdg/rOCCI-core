module Occi
  module Parser
    module Xml
      # @param [String] string
      # @return [Occi::Collection]
      def self.collection(string)

        hash = Hashie::Mash.new(Hash.from_xml(Nokogiri::XML(string)))

        unless hash
          Occi::Log.error "### Failed to parse XML input, nil returned"
          raise Occi::Errors::ParserInputError, 'Nothing returned by the parser'
        end

        Occi::Collection.new(hash)
      end
    end
  end
end