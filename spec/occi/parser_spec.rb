module Occi
  describe "Parser" do

    context ".parse" do

      context "render->parse tests" do
        let(:collection){ Occi::Collection.new }
        let(:resource){ collection.resources.create }
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
          let(:real_world_example_model) {
            {"Category" => "compute;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/compute/\",console;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute#\";class=\"kind\";location=\"/console/\",entity;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/entity/\",link;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/link/\",network;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/network/\",networkinterface;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/networkinterface/\",resource;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"kind\";location=\"/resource/\",storage;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/storage/\",storagelink;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/storagelink/\",compute;scheme=\"http://opennebula.org/occi/infrastructure#\";class=\"mixin\";location=\"/mixin/compute/\",extra_large;scheme=\"http://sitespecific.cesnet.cz/occi/infrastructure/resource_tpl#\";class=\"mixin\";location=\"/mixin/extra_large/\",ipnetwork;scheme=\"http://schemas.ogf.org/occi/infrastructure/network#\";class=\"mixin\";location=\"/mixin/ipnetwork/\",ipnetworkinterface;scheme=\"http://schemas.ogf.org/occi/infrastructure/networkinterface#\";class=\"mixin\";location=\"/mixin/ipnetworkinterface/\",large;scheme=\"http://sitespecific.cesnet.cz/occi/infrastructure/resource_tpl#\";class=\"mixin\";location=\"/mixin/large/\",medium;scheme=\"http://sitespecific.cesnet.cz/occi/infrastructure/resource_tpl#\";class=\"mixin\";location=\"/mixin/medium/\",network;scheme=\"http://opennebula.org/occi/infrastructure#\";class=\"mixin\";location=\"/mixin/network/\",networkinterface;scheme=\"http://opennebula.org/occi/infrastructure#\";class=\"mixin\";location=\"/mixin/networkinterface/\",os_tpl;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"mixin\";location=\"/mixin/os_tpl/\",public_key;scheme=\"http://schemas.openstack.org/instance/credentials#\";class=\"mixin\";location=\"/mixin/public_key/\",resource_tpl;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"mixin\";location=\"/mixin/resource_tpl/\",small;scheme=\"http://sitespecific.cesnet.cz/occi/infrastructure/resource_tpl#\";class=\"mixin\";location=\"/mixin/small/\",storage;scheme=\"http://opennebula.org/occi/infrastructure#\";class=\"mixin\";location=\"/mixin/storage/\",storagelink;scheme=\"http://opennebula.org/occi/infrastructure#\";class=\"mixin\";location=\"/mixin/storagelink/\",user_data;scheme=\"http://schemas.openstack.org/compute/instance#\";class=\"mixin\";location=\"/mixin/user_data/\",uuid_egi_compss_62;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_egi_compss_62/\",uuid_egi_compss_cesnet_57;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_egi_compss_cesnet_57/\",uuid_egi_compss_debian_7_0_x86_64_0001_cloud_dukan_74;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_egi_compss_debian_7_0_x86_64_0001_cloud_dukan_74/\",uuid_egi_sl6goldenimage_cesnet_50;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_egi_sl6goldenimage_cesnet_50/\",uuid_egi_test_compss_69;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_egi_test_compss_69/\",uuid_esa_sl64_cesnet_58;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_esa_sl64_cesnet_58/\",uuid_generic_vm_54;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_generic_vm_54/\",uuid_generic_www_60;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_generic_www_60/\",uuid_genericcloud_debian_7_0_x86_64_0001_cloud_dukan_71;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_genericcloud_debian_7_0_x86_64_0001_cloud_dukan_71/\",uuid_genericcloud_scilinux_6_5_x86_64_0001_cloud_dukan_73;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_genericcloud_scilinux_6_5_x86_64_0001_cloud_dukan_73/\",uuid_genericcloud_ubuntu_12_04_lts_x86_64_0001_cloud_dukan_72;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_genericcloud_ubuntu_12_04_lts_x86_64_0001_cloud_dukan_72/\",uuid_monitoring_20;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_monitoring_20/\",uuid_octave_55;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_octave_55/\",uuid_r_56;scheme=\"http://occi.localhost/occi/infrastructure/os_tpl#\";class=\"mixin\";location=\"/mixin/uuid_r_56/\""}
          }

          it 'parses self-generated collection with resources' do
            expect(Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rendered_collection).to_header).to eql rendered_collection
          end

          it 'parses self-generated collection with added attributes' do
            resource.id = UUIDTools::UUID.random_create.to_s
            resource.title = 'title'
            expect(Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rendered_collection).to_header).to eql rendered_collection
          end

          it 'parses self-generated collection with added mixin' do
            resource.mixins << Occi::Core::Mixin.new('http://schemas.ogf.org/occi/mymixins#', 'test')
            expect(Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rendered_collection).to_header).to eql rendered_collection
          end

          it 'parses self-generated collection with added link' do
            collection << link
            parsed = Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rendered_collection)
            expect(parsed.to_header).to eql rendered_collection
            expect(parsed.resources.first.links).not_to be_empty
          end

          it 'parses a real-world example of the OCCI model' do
            expect(Occi::Parser.parse('text/occi', '', true, Occi::Core::Resource, real_world_example_model).to_header.to_hash).to eql(real_world_example_model)
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

      it 'copes with non-existent MIME-type' do
        expect{ collection = Occi::Parser.parse('application/notexist', 'X-OCCI-Location: http://example.com:8090/a/b/vm1"') }.to raise_error(Occi::Errors::ParserTypeError)
      end

      it 'copes with type text/uri-list' do
        expect{ collection = Occi::Parser.parse('text/uri-list', 'http://example.com:8090/a/b/vm1"') }.to raise_error(Occi::Errors::ParserTypeError)
      end

      it 'skips type text/occi in body' do
        collection = Occi::Parser.parse('text/occi', 'Category: TERM;scheme="http://a.a/a#";class=kind')
        expected = Occi::Collection.new
        expect(collection).to eql expected
      end

    end

    context '.parse_headers' do
      let(:resource_in_headers) do
        resource = {}
        resource['Category'] = "network;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\",network;scheme=\"http://opennebula.org/occi/infrastructure#\";class=\"mixin\",ipnetwork;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"mixin\""
        resource['X-OCCI-Attribute'] = "occi.core.id=\"e4bd81c4-adda-5626-840d-39bb7959db97\",occi.core.title=\"monitoring\",occi.network.address=\"192.168.254.0\",occi.network.allocation=\"dynamic\",occi.network.state=\"active\",org.opennebula.network.id=\"6\",org.opennebula.network.bridge=\"xenbr0\",org.opennebula.network.vlan=\"NO\""
        resource
      end

      let(:rack_resource_in_headers) do
        resource = {}
        resource['HTTP_CATEGORY'] = resource_in_headers['Category']
        resource['HTTP_X_OCCI_ATTRIBUTE'] = resource_in_headers['X-OCCI-Attribute']
        resource
      end

      it 'parses categories' do
        categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rt").read
        categories = Occi::Parser.parse('text/plain', categories_string, true)
        expected = File.open("spec/occi/parser/text_samples/occi_categories.parse_headers.expected", "rt").read
        expect(categories.to_text).to eql expected
      end

      it 'parses resources from headers' do
        resource = Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, resource_in_headers)
        expected = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.resource.header.expected", "rt").read.chomp
        expect(resource.to_text).to eql expected
      end

      it 'parses resources from rack-compliant headers' do
        resource = Occi::Parser.parse('text/occi', '', false, Occi::Core::Resource, rack_resource_in_headers)
        expected = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.resource.rack.expected", "rt").read.chomp
        expect(resource.to_text).to eql expected
      end

      it 'parses link' do
        link_string = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.text", "rt").read
        link = Occi::Parser.parse('text/plain', link_string, false, Occi::Core::Link)
        expected = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.parse.expected", "rt").read.chomp
        expect(link.to_text).to eql expected
      end

      it 'fails gracefully for unknown entity type' do
        resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rt").read
        expect{ Occi::Parser.parse('text/plain', resource_string, false, Occi::Core::Action) }.to raise_error(Occi::Errors::ParserTypeError)
      end
    end

    context '.locations' do
      let(:expected){ ["http://example.com:8090/a/b/vm1", "http://example.com:8090/a/b/vm2"] }
      let(:single_expected){ ["http://example.com:8090/a/b/vm1"] }
      it 'parses single location from headers' do
        header = Hashie::Mash.new
        header['X-OCCI-Location'] = 'http://example.com:8090/a/b/vm1'
        location = Occi::Parser.locations("", "", header)
        expect(location).to eql single_expected
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

      it 'parses "Location" hashes from header, solo' do
        header = Hashie::Mash.new
        header['Location'] = "http://example.com:8090/a/b/vm1"
        location = Occi::Parser.locations("", "", header)
        expect(location).to eql single_expected
      end

      it 'parses "Location" hashes from header in combination with X-OCCI-Location strings' do
        header = Hashie::Mash.new
        header['Location'] = "http://example.com:8090/a/b/vm1"
        header['X-OCCI-Location'] = "http://example.com:8090/a/b/vm2"
        locations_text = "X-OCCI-Location: http://example.com:8090/a/b/vm1\nX-OCCI-Location: http://example.com:8090/a/b/vm2"
        location = Occi::Parser.locations("", "", header)
        expect(location).to eql expected
      end
    end

    context '.parse_body_plain' do
      it 'parses categories' do
        categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rt").read
        categories = Occi::Parser.parse('text/plain', categories_string, true)
        expected = File.open("spec/occi/parser/text_samples/occi_categories.body_plain.expected", "rt").read
        expect(categories.to_text).to eql expected
      end

      it 'parses resources' do
        resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rt").read
        resource = Occi::Parser.parse('text/plain', resource_string, false, Occi::Core::Resource)
        expected = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.body_plain.expected", "rt").read.chomp
        expect(resource.to_text).to eql expected
      end

      it 'parses links' do
        link_string = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.text", "rt").read
        link = Occi::Parser.parse('text/plain', link_string, false, Occi::Core::Link)
        expected = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.body_plain.expected", "rt").read.chomp
        expect(link.to_text).to eql expected
      end

      it 'copes with unknown entity type' do
        expect{Occi::Parser.parse('text/plain', 'Category: TERM;scheme="http://a.a/a#";class=kind', false, Occi::Core::Kind)}.to raise_exception(Occi::Errors::ParserTypeError)
        # This test works but the exception is actually raised in parse_headers(). Execution never gets to this branch in parse_body_plain()
      end
    end

    context 'output from other producers' do
      it 'parses input from FogBow Cloud' do
        category_string = File.open("spec/occi/parser/text_samples/occi_resource_custom_class_w_attributes.text", "rt").read
        collection = Occi::Parser.parse('text/plain', category_string)
        expected = File.open("spec/occi/parser/text_samples/occi_resource_custom_class_w_attributes.parse.expected", "rt").read.chomp
        expect(collection.to_text).to eql expected
      end

    end

  end
end
