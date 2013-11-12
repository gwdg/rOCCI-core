module Occi
  describe "Parser" do

    context ".parse" do

      context "render->parse tests" do
        let(:collection){ Occi::Collection.new }
        let(:resource){ resource = collection.resources.create }
        let(:link){ link = resource.links.create
            link.id = UUIDTools::UUID.random_create.to_s
            link.target = 'http://example.com/resource/aee5acf5-71de-40b0-bd1c-2284658bfd0e'
            link.source = resource
            link
        }

        context "resources from OCCI messages with text/plain MIME type" do
          let(:rendered_collection){ collection.to_text }

          it 'parses self-generated collection with resources' do
            expect(Occi::Parser.parse('text/plain', rendered_collection).to_json).to eql collection.to_json
          end

          it 'parses self-generated collection with added attributes' do
            resource.id = UUIDTools::UUID.random_create.to_s
            resource.title = 'title'
            expect(Occi::Parser.parse('text/plain', rendered_collection).to_json).to eql collection.to_json
          end

          it 'parses self-generated collection with added mixin' do
            resource.mixins << Occi::Core::Mixin.new
            expect(Occi::Parser.parse('text/plain', rendered_collection).to_json).to eql collection.to_json
          end

          it 'parses self-generated collection with added link' do
            collection << link
            expect(Occi::Parser.parse('text/plain', rendered_collection).to_json).to eql collection.to_json
          end
        end

        context 'resources from OCCI messages with text/occi MIME type' do
          let(:rendered_collection){ collection.to_header }

          it 'parses self-generated collection with resources' do
            expect(Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rendered_collection).to_header).to eql collection.to_header
          end

          it 'parses self-generated collection with added attributes' do
            resource.id = UUIDTools::UUID.random_create.to_s
            resource.title = 'title'
            expect(Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rendered_collection).to_header).to eql collection.to_header
          end

          it 'parses self-generated collection with added mixin' do
            resource.mixins << Occi::Core::Mixin.new
            expect(Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rendered_collection).to_header).to eql collection.to_header
          end

          it 'parses self-generated collection with added link' do
            collection << link
            expect(Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rendered_collection).to_header).to eql collection.to_header
          end
        end

        context 'resources from OCCI messages with application/occi+json MIME type' do
          let(:rendered_collection){ collection.to_json }
          it 'parses self-generated collection with resources' do
            expect(Occi::Parser.parse('application/occi+json', rendered_collection)).to eql collection
          end

          it 'parses self-generated collection with added attributes' do
            resource.id = UUIDTools::UUID.random_create.to_s
            resource.title = 'title'
            expect(Occi::Parser.parse('application/occi+json', rendered_collection)).to eql collection
          end

          it 'parses self-generated collection with added mixin' do
            resource.mixins << Occi::Core::Mixin.new
            expect(Occi::Parser.parse('application/occi+json', rendered_collection)).to eql collection
          end

          it 'parses self-generated collection with added link' #do #Already deactivated in previous version
#            collection << link
#            expect(Occi::Parser.parse('application/occi+json', rendered_collection)).to eql collection
#          end

        end
      end
    end

    it "parses an OVF file" do
      media_type = 'application/ovf+xml'
      body = File.read('spec/occi/parser/ovf_samples/test.ovf')
      collection = Occi::Parser.parse(media_type, body)

      collection.resources.each { |res| res.id="noid" } #Equalize auto-generated IDs

      expected = Marshal.load(File.open("spec/occi/parser/ovf_samples/test.dump", "rb"))
      expect(collection).to eql expected
    end

    it "parses an OVA container" do
      media_type = 'application/ova'
      body = File.read('spec/occi/parser/ova_samples/test.ova')
      collection = Occi::Parser.parse(media_type, body)

      collection.resources.each { |res| res.id="noid" } #Equalize auto-generated IDs

      expected = Marshal.load(File.open("spec/occi/parser/ova_samples/test.dump", "rb"))
      expect(collection).to eql expected
    end

#    ZS 11 Oct 2013: XML format not yet properly specified
#    it "parses a XML file" do
#      media_type = 'application/xml'
#      body = File.read('spec/occi/parser/xml_samples/test.xml')
#      collection = Occi::Parser.parse(media_type, body)
#      
#    end

    context '.parse_headers' do
      it 'parses categories' do
        categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rb").read
        expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_categories.dump", "rb"))
        categories = Occi::Parser.parse('text/plain', categories_string, true)
        expect(categories).to eql expected
      end

      it 'parses resources' do
        resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rb").read
        expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_network_rocci_server.resource.dump", "rb"))
        resource = Occi::Parser.parse('text/plain', resource_string, false, Occi::Core::Resource)
        expect(resource).to eql expected
      end

      it 'parses link' do
        link_string = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.text", "rb").read
        link = Occi::Parser.parse('text/plain', link_string, false, Occi::Core::Link)
        expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_link_resource_instance.dump", "rb"))
        expected.links.each { |exp| exp.id = 'emptied' }
        link.links.each { |lnk| lnk.id = 'emptied' }
        expect(link).to eql expected
      end

      it 'fails gracefully for unknown entity type' do
        resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rb").read
        expect{ Occi::Parser.parse('text/plain', resource_string, false, Occi::Core::ActionInstance) }.to raise_error(Occi::Errors::ParserTypeError)
      end
    end

    context '.locations' do
      let(:expected){ ["http://example.com:8090/a/b/vm1", "http://example.com:8090/a/b/vm2"] }
      it 'parses single location from headers' do
        header = Hashie::Mash.new
        header['X-OCCI-Location'] = 'http://example.com:8090/a/b/vm1'
        s_expected = ["http://example.com:8090/a/b/vm1"]
        location = Occi::Parser.locations("", "", header)
        expect(location).to eql s_expected
      end

      it 'parses multiple locations from headers' do
        header = Hashie::Mash.new
        header['X-OCCI-Location'] = "http://example.com:8090/a/b/vm1,http://example.com:8090/a/b/vm2"
        location = Occi::Parser.locations("", "", header)
        expect(location).to eql expected
      end

      it 'parses locations from headers, skipping attributes' do
        header = Hashie::Mash.new
        header['X-OCCI-Location'] = "http://example.com:8090/a/b/vm1,http://example.com:8090/a/b/vm2"
        header['X-OCCI-Attribute'] = "occi.core.title=\"test\""
        location = Occi::Parser.locations("", "", header)
        expect(location).to eql expected
      end

      it 'parses multiple locations from an URI list' do
        locations_text = "http://example.com:8090/a/b/vm1\nhttp://example.com:8090/a/b/vm2"
        location = Occi::Parser.locations("text/uri-list", locations_text, {})
        expect(location).to eql expected
      end      

      it 'parses multiple locations from plain text' do
        locations_text = "X-OCCI-Location: http://example.com:8090/a/b/vm1\nX-OCCI-Location: http://example.com:8090/a/b/vm2"
        location = Occi::Parser.locations("text/plain", locations_text, {})
        expect(location).to eql expected
      end      

      it 'copes with unmeaningful input' do
        location = Occi::Parser.locations("nonexistent", "", {})
        expect(location).to eql []
      end
    end

  end
end
