# encoding: UTF-8

module Occi
  module Parser
    describe Text do

      context '.category' do
        it 'parses a string describing an OCCI Category' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind";title="aA1!§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'
          category = Occi::Parser::Text.category category_string
          expect(category.to_text).to eql category_string
        end

        it 'parses a string describing an OCCI Category with unquoted class value' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind"'
          category = Occi::Parser::Text.category category_string
          expect(category.to_text).to eql "#{category_string};location=\"/a_a1-_/\""
        end

        it 'parses a string describing an OCCI Category with unquoted class value and explicit location' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind";location="/a_a1-_/"'
          category = Occi::Parser::Text.category category_string
          expect(category.to_text).to eql category_string
        end

        it 'parses a string describing an OCCI Category with uppercase term' do
          category_string = 'Category: TERM;scheme="http://a.a/a#";class="kind"'
          category = Occi::Parser::Text.category category_string
          expect(category.to_text).to eql 'Category: term;scheme="http://a.a/a#";class="kind";location="/term/"'
        end

        it 'parses a string describing an OCCI Category incl. attributes with properties' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="action";title="Restart Compute instance";attributes="method{required} test{immutable}"'
          category = Occi::Parser::Text.category category_string

          expect(category.attributes['method'].required).to be true
          expect(category.attributes['method'].mutable).to be true
          expect(category.attributes['test'].required).to be false
          expect(category.attributes['test'].mutable).to be false
        end

        it 'parses attributes correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_attributes.text", "rt").read
          category = Occi::Parser::Text.category resource_string
          expect(category.to_text).to eql "Category: compute;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/compute/\""
        end

        it 'parses inline links correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links_only.text", "rt").read
          category = Occi::Parser::Text.category resource_string
          expect(category.to_text).to eql "Category: compute;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/compute/\""
        end

        it 'parses inline Links and Mixins correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links.text", "rt").read
          category = Occi::Parser::Text.category resource_string
          expected = File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links.expected", "rt").read.chomp
          expect(category.to_text).to eql expected
        end

        it 'parses action correctly' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="action";title="Restart Compute instance";attributes="method"'
          category = Occi::Parser::Text.category category_string
          expect(category.to_text).to eql category_string
        end

        it 'parses network resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rt").read
          category = Occi::Parser::Text.category resource_string
          expect(category.to_text).to eql "Category: network;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/network/\""
        end

        it 'parses storage resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.text", "rt").read
          category = Occi::Parser::Text.category resource_string
          expect(category.to_text).to eql "Category: storage;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/storage/\""
        end

        it 'parses compute resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rt").read
          category = Occi::Parser::Text.category resource_string
          expect(category.to_text).to eql "Category: compute;scheme=\"http://schemas.ogf.org/occi/infrastructure#\";class=\"kind\";location=\"/compute/\""
        end

        it 'parses model from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_model_rocci_server.text", "rt").read
          category = Occi::Parser::Text.category resource_string

        end

        it 'raises error for obviously nonsensical class' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="actions";title="Restart Compute instance";attributes="method"'
          expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
        end

        it 'raises error for cleverly nonsensical class' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="action|mixin";title="Restart Compute instance";attributes="method"'
          expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
        end

        it 'raises error for a nonsensical class even with lenient regexp' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="invalid";title="Restart Compute instance";attributes="method"'

          regexp_category = Occi::Parser::Text::Constants.const_get('REGEXP_CATEGORY')
          regexp_category_alt = regexp_category
          regexp_category_alt['action'] = 'invalid'

          Occi::Parser::Text::Constants.const_set('REGEXP_CATEGORY', regexp_category_alt)

          expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          Occi::Parser::Text.const_set('REGEXP_CATEGORY', regexp_category)
        end
      end

      context '.resource' do
        it 'parses network resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rt").read
          resource = Occi::Parser::Text.resource resource_string
          expected = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.expected", "rt").read.chomp
          expect(resource.to_text).to eql expected
        end

        it 'parses storage resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.text", "rt").read
          resource = Occi::Parser::Text.resource resource_string
          expected = File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.expected", "rt").read.chomp
          expect(resource.to_text).to eql expected
        end

        it 'parses compute resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rt").read
          resource = Occi::Parser::Text.resource resource_string
          expected = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.expected", "rt").read.chomp
          expect(resource.to_text).to eql expected
        end

        it 'types parsed compute resource from rOCCI server as Occi::Infrastructure::Compute' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rt").read
          expected_class = Occi::Infrastructure::Compute
          resource_class = Occi::Parser::Text.resource(resource_string).resources.first.class
          expect(resource_class).to eql expected_class
        end

        it 'types parsed custom resource as related to Occi::Core::Resource' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_custom_class_w_attributes.text", "rt").read
          expected_class = "Org::Fogbowcloud::Schemas::Request::FogbowRequest"

          resource_instance = Occi::Parser::Text.resource(resource_string).resources.first
          resource_class = resource_instance.class.to_s
          expect(resource_class).to eql expected_class
          expect(resource_instance).to be_kind_of Occi::Core::Resource
        end
      end

      context '.categories' do
        it 'parses strings describing OCCI Categories' do
          categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rt").read
          categories = Occi::Parser::Text.categories categories_string
          expected = File.open("spec/occi/parser/text_samples/occi_categories.expected", "rt").read
          expect(categories.to_text).to eql expected
        end

        it 'parses strings describing OCCI Categories, skipping unparseable additions' do
          categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rt").read
          categories_string["\n"] = "\n\n&*$this won't parse\n"
          categories = Occi::Parser::Text.categories categories_string
          expected = File.open("spec/occi/parser/text_samples/occi_categories.expected", "rt").read
          expect(categories.to_text).to eql expected
        end

        it 'does not fail on unparseable input' do
          categories_string = "\n\n&*$this won't parse\n"
          categories = Occi::Parser::Text.categories categories_string
          expect(categories.blank?).to eql true
        end

      end

      context '.link' do
        it 'parses link resource instance' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.text", "rt").read
          link = Occi::Parser::Text.link link_string
          expected = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.expected", "rt").read.chomp
          expect(link.to_text).to eql expected
        end

      end

      context '.location' do
        it 'parses single location' do
          location_string = "X-OCCI-Location: http://example.com:8090/a/b/vm1"
          location = Occi::Parser::Text.location location_string
          expected = "http://example.com:8090/a/b/vm1"
          expect(location).to eql expected
        end
      end

      context '.locations' do
        let(:locations_string){ "X-OCCI-Location: http://example.com:8090/a/b/vm1\nX-OCCI-Location: http://example.com:8090/a/b/vm2" }
        let(:expected){ ["http://example.com:8090/a/b/vm1", "http://example.com:8090/a/b/vm2"] }

        it 'parses multiple locations' do
          locations = Occi::Parser::Text.locations locations_string
          expect(locations).to eql expected
        end

        it 'parses multiple locations, skipping unparseable additions' do
          locations_string["\n"] = "\n\n&*$this won't parse\n"
          locations = Occi::Parser::Text.locations locations_string
          expect(locations).to eql expected
        end
      end

      context '.attribute' do
      end

      context '.link_string' do
        it 'parses string with category set' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_simple.text", "rt").read
          link = Occi::Parser::Text.link_string link_string, nil
          expected = File.open("spec/occi/parser/text_samples/occi_link_simple.expected", "rt").read.chomp
          expect(link.to_text).to eql expected
        end

        it 'parses link with category' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_w_category.text", "rt").read
          link = Occi::Parser::Text.link_string link_string, nil
          expected = File.open("spec/occi/parser/text_samples/occi_link_w_category.expected", "rt").read.chomp
          expect(link.to_text).to eql expected
        end

        it 'parses link with attributes' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_w_attributes.text", "rt").read
          link = Occi::Parser::Text.link_string link_string, nil
          expected = File.open("spec/occi/parser/text_samples/occi_link_w_attributes.expected", "rt").read.chomp
          expect(link.to_text).to eql expected
        end

        it 'parses string with action link' do
          link_string = 'Link: </compute/04106bce-87eb-4f8f-a665-2f624e54ba46?action=restart>; rel="http://schemas.ogf.org/occi/infrastructure/compute/action#restart"'
          link = Occi::Parser::Text.link_string(link_string, "source")
          expect(link.to_text).to eql "Category: restart;scheme=\"http://schemas.ogf.org/occi/infrastructure/compute/action#\";class=\"action\""
        end
      end

      context 'compatibility' do
        after(:each) { Occi::Settings.reload! }
        context 'terms' do
          it 'parses uppercase term, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: TERM;scheme="http://a.a/a#";class="kind"'
            category = Occi::Parser::Text.category category_string
            expect(category.to_text).to eql "Category: term;scheme=\"http://a.a/a#\";class=\"kind\";location=\"/term/\""
          end

          it 'refuses uppercase term, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: TERM;scheme="http://a.a/a#";class="kind"'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end

          it 'parses term starting with number, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: 1TERM;scheme="http://a.a/a#";class="kind"'
            category = Occi::Parser::Text.category category_string
            expect(category.to_text).to eql "Category: 1term;scheme=\"http://a.a/a#\";class=\"kind\";location=\"/1term/\""
          end

          it 'refuses term starting with number, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: 1TERM;scheme="http://a.a/a#";class=kind'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end


          it 'parses upper case Category with compatibility mode on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: A_A1-_;scheme="http://a.a/a#";class="kind"'
            expect{ category = Occi::Parser::Text.category category_string }.to_not raise_error
          end

          it 'refuses upper case Category with compatibility mode off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: A_A1-_;scheme="http://a.a/a#";class="kind"'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end

        end

        context 'schemes' do
          it 'parses a Category, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: a_a1-_;scheme="http://a.a/a#a_a1-_";class="kind";title="aA1!§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'
            category = Occi::Parser::Text.category category_string
            expect(category.to_text).to eql "Category: a_a1-_;scheme=\"http://a.a/a#\";class=\"kind\";title=\"aA1!§$%&/()=?`´ß+*#-_.:,;<>\";rel=\"http://a.a/b#a\";location=\"/a1-A/\";attributes=\"a_1-_.a1-_a a-1.a.b\";actions=\"http://a.a/a1#a1 http://a.b1/b1#b2\""
          end

          it 'parses a Category, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: a_a1-_;scheme="http://a.a/a#a_a1-_";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end
        end
      end

      context 'with other OCCI implementations' do

        it 'correctly parses input from FogBow Cloud' do
          category_string = File.open("spec/occi/parser/text_samples/occi_resource_custom_class_w_attributes.text", "rt").read
          category = Occi::Parser::Text.category category_string
          expected = "Category: fogbow_request;scheme=\"http://schemas.fogbowcloud.org/request#\";class=\"kind\";title=\"Request new Instances\";rel=\"http://schemas.ogf.org/occi/core#resource\";location=\"/fogbow_request/\";attributes=\"org.fogbowcloud.request.instance-count org.fogbowcloud.request.type org.fogbowcloud.request.valid-until org.fogbowcloud.request.valid-from org.fogbowcloud.request.state org.fogbowcloud.request.instance-id\""
          expect(category.to_text).to eql expected
        end 

        it 'renders correctly OCCI from other sources'
      end

    end
  end
end
