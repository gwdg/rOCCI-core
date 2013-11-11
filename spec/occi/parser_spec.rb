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

  end
end
