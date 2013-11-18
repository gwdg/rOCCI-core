# encoding: UTF-8

module Occi
  module Parser
    describe Text do

      context '.category' do

        it 'parses a string describing an OCCI Category' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'

          category = Occi::Parser::Text.category category_string
          expected = Marshal.restore("\x04\bo:\x15Occi::Core::Kind\r:\f@schemeI\"\x12http://a.a/a#\x06:\x06ET:\n@termI\"\va_a1-_\x06;\aT:\v@titleI\"%aA1!\\\"\xC2\xA7$%&/()=?`\xC2\xB4\xC3\x9F+*#-_.:,;<>\x06;\aT:\x10@attributesC:\eOcci::Core::Attributes{\aI\"\na_1-_\x06;\aTC;\v{\x06I\"\na1-_a\x06;\aTo:\eOcci::Core::Properties\v:\r@default0:\n@typeI\"\vstring\x06;\aF:\x0E@requiredF:\r@mutableF:\r@patternI\"\a.*\x06;\aF:\x11@description0I\"\ba-1\x06;\aTC;\v{\x06I\"\x06a\x06;\aTC;\v{\x06I\"\x06b\x06;\aTo;\f\v;\r0;\x0EI\"\vstring\x06;\aF;\x0FF;\x10F;\x11I\"\a.*\x06;\aF;\x120:\f@parentI\"\x13http://a.a/b#a\x06;\aT:\r@actionso:\x18Occi::Core::Actions\x06:\n@hash{\ao:\x17Occi::Core::Action\t;\x06I\"\x13http://a.a/a1#\x06;\aT;\bI\"\aa1\x06;\aT;\t0;\nC;\v{\x00To;\x17\t;\x06I\"\x14http://a.b1/b1#\x06;\aT;\bI\"\ab2\x06;\aT;\t0;\nC;\v{\x00T:\x0E@entitieso:\x19Occi::Core::Entities\x06;\x16{\x00:\x0E@locationI\"\v/a1-A/\x06;\aT")

          expect(category).to eql expected
        end

        it 'parses a string describing an OCCI Category with unquoted class value' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class=kind'
          expected = Marshal.restore("\x04\bo:\x15Occi::Core::Kind\r:\f@schemeI\"\x12http://a.a/a#\x06:\x06ET:\n@termI\"\va_a1-_\x06;\aT:\v@title0:\x10@attributesC:\eOcci::Core::Attributes{\x00:\f@parent0:\r@actionso:\x18Occi::Core::Actions\x06:\n@hash{\x00:\x0E@entitieso:\x19Occi::Core::Entities\x06;\x0F{\x00:\x0E@locationI\"\r/a_a1-_/\x06;\aF")
          category = Occi::Parser::Text.category category_string
          expect(category).to eql expected
        end

        it 'parses a string describing an OCCI Category with uppercase term' do
          category_string = 'Category: TERM;scheme="http://a.a/a#";class=kind'
          expected = Marshal.restore("\x04\bo:\x15Occi::Core::Kind\r:\f@schemeI\"\x12http://a.a/a#\x06:\x06ET:\n@termI\"\tterm\x06;\aT:\v@title0:\x10@attributesC:\eOcci::Core::Attributes{\x00:\f@parent0:\r@actionso:\x18Occi::Core::Actions\x06:\n@hash{\x00:\x0E@entitieso:\x19Occi::Core::Entities\x06;\x0F{\x00:\x0E@locationI\"\v/term/\x06;\aF")
          category = Occi::Parser::Text.category category_string
          expect(category).to eql expected
        end


        it 'parses attributes correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_attributes.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_resource_w_attributes.dump", "rb"))
          collection = Occi::Parser::Text.category resource_string
          expect(collection).to eql expected
        end

        it 'parses inline links correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links_only.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links_only.dump", "rb"))
          collection = Occi::Parser::Text.category resource_string
          expect(collection).to eql expected
        end

        it 'parses inline Links and Mixins correctly' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links.dump", "rb"))
          collection = Occi::Parser::Text.category resource_string
          expect(collection).to eql expected
        end

        it 'parses action correctly' do
          category_string = 'Category: restart;scheme="http://schemas.ogf.org/occi/infrastructure/compute/action#";class="action";title="Restart Compute instance";attributes="method"'
          category = Occi::Parser::Text.category category_string
          expected = Marshal.restore("\x04\bo:\x17Occi::Core::Action\t:\f@schemeI\"?http://schemas.ogf.org/occi/infrastructure/compute/action#\x06:\x06ET:\n@termI\"\frestart\x06;\aT:\v@titleI\"\x1DRestart Compute instance\x06;\aT:\x10@attributesC:\eOcci::Core::Attributes{\x06I\"\vmethod\x06;\aTo:\eOcci::Core::Properties\v:\r@default0:\n@typeI\"\vstring\x06;\aF:\x0E@requiredF:\r@mutableF:\r@patternI\"\a.*\x06;\aF:\x11@description0")

          expect(category).to eql expected
        end

        it 'parses network resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_network_rocci_server.dump", "rb"))
          collection =  Occi::Parser::Text.category resource_string
          expect(collection).to eql expected
        end
        
        it 'parses storage resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.dump", "rb"))
          collection =  Occi::Parser::Text.category resource_string
          expect(collection).to eql expected
        end
        
        it 'parses compute resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.dump", "rb"))
          collection =  Occi::Parser::Text.category resource_string
          expect(collection).to eql expected
        end
        
        it 'parses model from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_model_rocci_server.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_model_rocci_server.dump", "rb"))
          collection =  Occi::Parser::Text.category resource_string
          expect(collection).to eql expected
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
          resource_string = File.open("spec/occi/parser/text_samples/occi_network_rocci_server.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_network_rocci_server.resource.dump", "rb"))
          resource =  Occi::Parser::Text.resource resource_string
          expect(resource).to eql expected
        end

        it 'parses storage resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_storage_rocci_server.resource.dump", "rb"))
          resource =  Occi::Parser::Text.resource resource_string
          expect(resource).to eql expected
        end
        
        it 'parses compute resource from rOCCI server' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.resource.dump", "rb"))
          resource =  Occi::Parser::Text.resource resource_string
          expect(resource).to eql expected
        end

        it 'types parsed compute resource from rOCCI server as Occi::Infrastructure::Compute' do
          resource_string = File.open("spec/occi/parser/text_samples/occi_compute_rocci_server.text", "rb").read
          expected_class = Occi::Infrastructure::Compute
          resource_class =  Occi::Parser::Text.resource(resource_string).resources.first.class
          expect(resource_class).to eql expected_class
        end
      end

      context '.categories' do
        it 'parses strings describing OCCI Categories' do
          categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rb").read
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_categories.dump", "rb"))
          categories = Occi::Parser::Text.categories categories_string
          expect(categories).to eql expected
        end

        it 'parses strings describing OCCI Categories, skipping unparseable additions' do
          categories_string = File.open("spec/occi/parser/text_samples/occi_categories.text", "rb").read
          categories_string["\n"] = "\n\n&*$this won't parse\n"
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_categories.dump", "rb"))
          categories = Occi::Parser::Text.categories categories_string
          expect(categories).to eql expected
        end

        it 'does not fail on unparseable input' do
          categories_string = "\n\n&*$this won't parse\n"
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_categories.dump", "rb"))
          categories = Occi::Parser::Text.categories categories_string
          expect(categories.blank?).to eql true
        end

      end

      context '.link' do
        it 'parses link resource instance' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_resource_instance.text", "rb").read
          link = Occi::Parser::Text.link link_string
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_link_resource_instance.dump", "rb"))
          expected.links.each { |exp| exp.id = 'emptied' }
          link.links.each { |lnk| lnk.id = 'emptied' }
          expect(link).to eql expected
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
          link_string = File.open("spec/occi/parser/text_samples/occi_link_simple.text", "rb").read
          link = Occi::Parser::Text.link_string link_string, nil
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_link_simple.link_string.dump", "rb"))
          expect(link).to eql expected
        end

        it 'parses link with category' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_w_category.text", "rb").read
          link = Occi::Parser::Text.link_string link_string, nil
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_link_w_category.dump", "rb"))
          expect(link).to eql expected
        end

        it 'parses link with attributes' do
          link_string = File.open("spec/occi/parser/text_samples/occi_link_w_attributes.text", "rb").read
          link = Occi::Parser::Text.link_string link_string, nil
          expected = Marshal.load(File.open("spec/occi/parser/text_samples/occi_link_w_attributes.dump", "rb"))
          expect(link).to eql expected
        end

        it 'parses string with category unset' do
          link_string = 'Link: </compute/04106bce-87eb-4f8f-a665-2f624e54ba46?action=restart>; rel="http://schemas.ogf.org/occi/infrastructure/compute/action#restart"'
          link = Occi::Parser::Text.link_string(link_string, "source")
          expected = Marshal.restore("\x04\bo:\x15Occi::Core::Link\x0E:\n@kindo:\x15Occi::Core::Kind\r:\f@schemeI\"&http://schemas.ogf.org/occi/core#\x06:\x06EF:\n@termI\"\tlink\x06;\tF:\v@titleI\"\tlink\x06;\tF:\x10@attributesC:\eOcci::Core::Attributes{\x06I\"\tocci\x06;\tFC;\r{\x06I\"\tcore\x06;\tFC;\r{\rI\"\aid\x06;\tFo:\eOcci::Core::Properties\v:\r@default0:\n@typeI\"\vstring\x06;\tF:\x0E@requiredF:\r@mutableF:\r@patternI\"A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\x06;\tF:\x11@description0I\"\b_id\x06;\tFo;\x0E\v;\x0F0;\x10@\x11;\x11F;\x12F;\x13@\x12;\x140I\"\ntitle\x06;\tFo;\x0E\v;\x0F0;\x10I\"\vstring\x06;\tF;\x11F;\x12T;\x13I\"\a.*\x06;\tF;\x140I\"\v_title\x06;\tFo;\x0E\v;\x0F0;\x10@\x17;\x11F;\x12T;\x13@\x18;\x140I\"\vtarget\x06;\tFo;\x0E\v;\x0F0;\x10I\"\vstring\x06;\tF;\x11F;\x12T;\x13I\"\a.*\x06;\tF;\x140I\"\f_target\x06;\tFo;\x0E\v;\x0F0;\x10@\x1D;\x11F;\x12T;\x13@\x1E;\x140I\"\vsource\x06;\tFo;\x0E\v;\x0F0;\x10I\"\vstring\x06;\tF;\x11F;\x12T;\x13I\"\a.*\x06;\tF;\x140I\"\f_source\x06;\tFo;\x0E\v;\x0F0;\x10@#;\x11F;\x12T;\x13@$;\x140:\f@parento;\a\r;\bI\"&http://schemas.ogf.org/occi/core#\x06;\tF;\nI\"\ventity\x06;\tF;\vI\"\ventity\x06;\tF;\fC;\r{\x06@\vC;\r{\x06@\rC;\r{\t@\x0F@\x10@\x13@\x14@\x15@\x16@\x19@\x1A;\x150:\r@actionso:\x18Occi::Core::Actions\x06:\n@hash{\x00:\x0E@entitieso:\x19Occi::Core::Entities\x06;\x18{\x00:\x0E@locationI\"\r/entity/\x06;\tF;\x16o;\x17\x06;\x18{\x00;\x19o;\x1A\x06;\x18{\x00;\eI\"\v/link/\x06;\tF:\f@mixinso:\x17Occi::Core::Mixins\a;\x18{\x00:\f@entity@\x00;\fIC;\r{\x06@\vIC;\r{\x06@\rIC;\r{\r@\x0F0@\x13@\x14@\x150@\x19@\x1A@\e0@\x1F@ @!0@%@&\x06:\x0F@convertedT\x06;\x1FT\x06;\x1FT;\x16o;\x17\x06;\x18{\x00;\e0:\t@relo;\a\r;\bI\"?http://schemas.ogf.org/occi/infrastructure/compute/action#\x06;\tT;\nI\"\frestart\x06;\tT;\v0;\fC;\r{\x00;\x15@';\x16o;\x17\x06;\x18{\x00;\x19o;\x1A\x06;\x18{\x00;\eI\"\x0E/restart/\x06;\tF:\f@sourceI\"\vsource\x06;\tT:\f@targetI\"A/compute/04106bce-87eb-4f8f-a665-2f624e54ba46?action=restart\x06;\tT:\b@id0")
          expected.id = 'epmtied'
          link.id = 'epmtied'
          expect(link).to eql expected
        end
      end

      context 'compatibility' do
        after(:each) { Occi::Settings.reload! }
        context 'terms' do
          it 'parses uppercase term, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: TERM;scheme="http://a.a/a#";class=kind'
            expected = Marshal.restore("\x04\bo:\x15Occi::Core::Kind\r:\f@schemeI\"\x12http://a.a/a#\x06:\x06ET:\n@termI\"\tterm\x06;\aT:\v@title0:\x10@attributesC:\eOcci::Core::Attributes{\x00:\f@parent0:\r@actionso:\x18Occi::Core::Actions\x06:\n@hash{\x00:\x0E@entitieso:\x19Occi::Core::Entities\x06;\x0F{\x00:\x0E@locationI\"\v/term/\x06;\aF")
            category = Occi::Parser::Text.category category_string
            expect(category).to eql expected
          end

          it 'refuses uppercase term, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: TERM;scheme="http://a.a/a#";class=kind'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end

          it 'parses term starting with number, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: 1TERM;scheme="http://a.a/a#";class=kind'
            expected = Marshal.restore("\x04\bo:\x15Occi::Core::Kind\r:\f@schemeI\"\x12http://a.a/a#\x06:\x06ET:\n@termI\"\n1term\x06;\aT:\v@title0:\x10@attributesC:\eOcci::Core::Attributes{\x00:\f@parent0:\r@actionso:\x18Occi::Core::Actions\x06:\n@hash{\x00:\x0E@entitieso:\x19Occi::Core::Entities\x06;\x0F{\x00:\x0E@locationI\"\f/1term/\x06;\aF")
            category = Occi::Parser::Text.category category_string
            expect(category).to eql expected
          end

          it 'refuses term starting with number, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: 1TERM;scheme="http://a.a/a#";class=kind'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end

        end
        context 'schemes' do
          it 'parses a Category, compatibility on' do
            Occi::Settings['compatibility']=true
            category_string = 'Category: a_a1-_;scheme="http://a.a/a#a_a1-_";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'
            category = Occi::Parser::Text.category category_string
            expected = Marshal.restore("\x04\bo:\x15Occi::Core::Kind\r:\f@schemeI\"\x12http://a.a/a#\x06:\x06ET:\n@termI\"\va_a1-_\x06;\aT:\v@titleI\"%aA1!\\\"\xC2\xA7$%&/()=?`\xC2\xB4\xC3\x9F+*#-_.:,;<>\x06;\aT:\x10@attributesC:\eOcci::Core::Attributes{\aI\"\na_1-_\x06;\aTC;\v{\x06I\"\na1-_a\x06;\aTo:\eOcci::Core::Properties\v:\r@default0:\n@typeI\"\vstring\x06;\aF:\x0E@requiredF:\r@mutableF:\r@patternI\"\a.*\x06;\aF:\x11@description0I\"\ba-1\x06;\aTC;\v{\x06I\"\x06a\x06;\aTC;\v{\x06I\"\x06b\x06;\aTo;\f\v;\r0;\x0EI\"\vstring\x06;\aF;\x0FF;\x10F;\x11I\"\a.*\x06;\aF;\x120:\f@parentI\"\x13http://a.a/b#a\x06;\aT:\r@actionso:\x18Occi::Core::Actions\x06:\n@hash{\ao:\x17Occi::Core::Action\t;\x06I\"\x13http://a.a/a1#\x06;\aT;\bI\"\aa1\x06;\aT;\t0;\nC;\v{\x00To;\x17\t;\x06I\"\x14http://a.b1/b1#\x06;\aT;\bI\"\ab2\x06;\aT;\t0;\nC;\v{\x00T:\x0E@entitieso:\x19Occi::Core::Entities\x06;\x16{\x00:\x0E@locationI\"\v/a1-A/\x06;\aT")
            expect(category).to eql expected
          end

          it 'parses a Category, compatibility off' do
            Occi::Settings['compatibility']=false
            category_string = 'Category: a_a1-_;scheme="http://a.a/a#a_a1-_";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'
            expect{ category = Occi::Parser::Text.category category_string }.to raise_error(Occi::Errors::ParserInputError)
          end
        end
      end

      context 'other OCCI implementations' do
        it 'renders correctly OCCI from other sources'
      end

    end
  end
end
