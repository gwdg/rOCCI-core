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
          collection =  Occi::Parser::Text.category resource_string
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
          collection =  Occi::Parser::Text.category resource_string
          expect(collection).to eql expected
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
        
      end
      context '.resource' do
      end
      context '.categories' do
        it 'parses all above as lines'
      end
      context '.resource' do
      end
      context '.link' do
      end
      context '.location' do
      end
      context '.locations' do
      end
      context '.attribute' do
      end
      context '.link_string' do
      end
      context 'other OCCI implementations' do
        it 'renders correctly OCCI from other sources'
      end
    end
  end
end
