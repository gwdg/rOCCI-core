# encoding: UTF-8

module Occi
  module Parser
    describe Text do

      context '.category' do

        it 'parses a string describing an OCCI Category' #do
#          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'

          # TODO: compare objects directly, do not rely on text rendering
#          expected = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind";title="aA1!"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'

#          category = Occi::Parser::Text.category category_string
#          expect(category.to_text).to eq expected
#        end

        it 'parses a string describing an OCCI Category with unquoted class value' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class=kind'

          # TODO: compare objects directly, do not rely on text rendering
          expected = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind";location="/a_a1-_/"'

          category = Occi::Parser::Text.category category_string
          expect(category.to_text).to eql expected
        end

        it 'parses a string describing an OCCI Category with uppercase term' do
          category_string = 'Category: TERM;scheme="http://a.a/a#";class=kind'

          category = Occi::Parser::Text.category category_string
          category.term.should eq 'term'
          category.scheme.should eq 'http://a.a/a#'
          category.class.should eq Occi::Core::Kind
        end

      end

      context '.resource' do
        context 'attributes' do
          let(:resource_string){ File.open("spec/occi/parser/text_samples/occi_resource_w_attributes.text", "rb").read }
          let(:collection){ Occi::Parser::Text.resource resource_string.lines }

          it 'parses No. of cores' do
            expect(collection.resources.first.attributes['occi.compute.cores']).to eq 1
          end
          it 'parses compute cpu' do
            expect(collection.resources.first.attributes['org.opennebula.compute.cpu']).to eq 1.0
          end
          it 'parses architecture' do
            expect(collection.resources.first.attributes['occi.compute.architecture']).to eq "x86"
          end
          it 'parses compute memory' do
            expect(collection.resources.first.attributes['occi.compute.memory']).to eq 1.7
          end
        end

        context 'inline links' do
          let(:resource_string){ File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links_only.text", "rb").read }
          let(:collection){ Occi::Parser::Text.resource resource_string.lines }

          it 'has the right number of resources' do
            expect(collection.resources).to have(1).resource
          end
          it 'has the right number of links' do
            expect(collection.links).to have(2).links
          end
        end

        context 'inline Links and Mixins' do
          let(:resource_string){ File.open("spec/occi/parser/text_samples/occi_resource_w_inline_links.text", "rb").read }
          let(:collection){ Occi::Parser::Text.resource resource_string.lines }

          it 'has the right number of resources' do
            expect(collection.resources).to have(1).resource
          end
          it 'has the right number of links' do
            expect(collection.links).to have(5).links
          end
        end
      end
    end
  end
end
