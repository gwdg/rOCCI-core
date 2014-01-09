module Occi
  module Parser
    module Json
      # @param [String] body
      # @return [Occi::Collection]
      def self.collection(body)

        begin
          hash = Hashie::Mash.new(JSON.parse(body))
        rescue JSON::ParserError => perr
          Occi::Log.error "[#{self}] Failed to parse JSON input: #{perr.message}"
          raise Occi::Errors::ParserInputError, perr.message
        end

        hash = { :action => hash } if hash && hash.action
        collection = Occi::Collection.new(hash)

        if collection.resources.size == 1 && collection.links.size > 0
          if collection.resources.first.links.empty?
            collection.links.each { |link| link.source = collection.resources.first }
            collection.resources.first.links = collection.links
          end
        end

        # TODO: replace the following mechanism with one in the Links class
        # replace link locations with link objects in all resources
        collection.resources.each do |resource|
          resource.links.collect! do |resource_link|
            lnk = collection.links.select { |link| resource_link == link.to_s }.first
            lnk ||= resource_link
          end
        end

        collection
      end
    end
  end
end