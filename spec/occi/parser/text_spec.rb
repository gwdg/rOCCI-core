# encoding: UTF-8

module Occi
  module Parser
    describe Text do

      describe '.category' do

        it 'parses a string describing an OCCI Category' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class="kind";title="aA1!\"§$%&/()=?`´ß+*#-_.:,;<>";rel="http://a.a/b#a";location="/a1-A/";attributes="a_1-_.a1-_a a-1.a.b";actions="http://a.a/a1#a1 http://a.b1/b1#b2"'

          category = Occi::Parser::Text.category category_string
          category.term.should eq 'a_a1-_'
          category.scheme.should eq 'http://a.a/a#'
          category.class.should eq Occi::Core::Kind
          category.title.should eq 'aA1!\"§$%&/()=?`´ß+*#-_.:,;<>'
          category.related.first.should eq 'http://a.a/b#a'
          category.location.should eq '/a1-A/'
          category.attributes['a_1-_'].class.should eq Occi::Core::Attributes
          category.attributes['a_1-_']['a1-_a'].class.should eq Occi::Core::Properties
          category.attributes['a-1'].class.should eq Occi::Core::Attributes
          category.attributes['a-1']['a'].class.should eq Occi::Core::Attributes
          category.attributes['a-1']['a']['b'].class.should eq Occi::Core::Properties
          category.actions.to_a.any? {|action| action.to_s == 'http://a.a/a1#a1'}.should be_true
          category.actions.to_a.any? {|action| action.to_s == 'http://a.b1/b1#b2'}.should be_true
        end

        it 'parses a string describing an OCCI Category with unquoted class value' do
          category_string = 'Category: a_a1-_;scheme="http://a.a/a#";class=kind'

          category = Occi::Parser::Text.category category_string
          category.term.should eq 'a_a1-_'
          category.scheme.should eq 'http://a.a/a#'
          category.class.should eq Occi::Core::Kind
        end

        it 'parses a string describing an OCCI Category with uppercase term' do
          category_string = 'Category: TERM;scheme="http://a.a/a#";class=kind'

          category = Occi::Parser::Text.category category_string
          category.term.should eq 'term'
          category.scheme.should eq 'http://a.a/a#'
          category.class.should eq Occi::Core::Kind
        end

      end

      describe '.resource' do

        it 'parses a string with an OCCI Resource including attributes' do
          resource_string = %Q|Category: compute;scheme="http://schemas.ogf.org/occi/infrastructure#";class="kind"\nCategory: compute;scheme="http://opennebula.org/occi/infrastructure#";class="mixin"|
          resource_string << %Q|\nCategory: monitoring;scheme="https://occi.carach5.ics.muni.cz/occi/infrastructure/os_tpl#";class="mixin"|
          resource_string << %Q|\nCategory: small;scheme="https://occi.carach5.ics.muni.cz/occi/infrastructure/resource_tpl#";class="mixin"|
          resource_string << %Q|\nX-OCCI-Attribute: occi.core.id="ee13808d-7708-4341-a4ba-0e42e4818218"|
          resource_string << %Q|\nX-OCCI-Attribute: occi.core.title="TestVM"|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.cores=1|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.memory=1.7|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.architecture="x86"|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.speed=1|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.state="active"|
          resource_string << %Q|\nX-OCCI-Attribute: org.opennebula.compute.cpu=1.0|

          collection = Occi::Parser::Text.resource resource_string.lines
          collection.resources.first.attributes['occi.compute.cores'].should eq(1)
          collection.resources.first.attributes['org.opennebula.compute.cpu'].should eq(1.0)
          collection.resources.first.attributes['occi.compute.architecture'].should eq("x86")
          collection.resources.first.attributes['occi.compute.memory'].should eq(1.7)
        end

        it 'parses a string with an OCCI Resource including inline OCCI Link definitions' do
          resource_string = %Q|Category: compute;scheme="http://schemas.ogf.org/occi/infrastructure#";class="kind"\nCategory: compute;scheme="http://opennebula.org/occi/infrastructure#";class="mixin"|
          resource_string << %Q|\nCategory: monitoring;scheme="https://occi.carach5.ics.muni.cz/occi/infrastructure/os_tpl#";class="mixin"|
          resource_string << %Q|\nCategory: small;scheme="https://occi.carach5.ics.muni.cz/occi/infrastructure/resource_tpl#";class="mixin"|
          resource_string << %Q|\nX-OCCI-Attribute: occi.core.id="ee13808d-7708-4341-a4ba-0e42e4818218"|
          resource_string << %Q|\nX-OCCI-Attribute: occi.core.title="TestVM"|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.cores=1|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.memory=1.7|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.architecture="x86"|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.speed=1|
          resource_string << %Q|\nX-OCCI-Attribute: occi.compute.state="active"|
          resource_string << %Q|\nX-OCCI-Attribute: org.opennebula.compute.cpu=1.0|
          resource_string << %Q|\nLink: </storage/e60aa2b8-0c86-5973-b93e-30c5c46d6eac>;rel="http://schemas.ogf.org/occi/infrastructure#storage";self="/storagelink/b2f7f1de-c60c-5b08-879c-81f52429c4ef";category="http://schemas.ogf.org/occi/infrastructure#storagelink";occi.core.id="b2f7f1de-c60c-5b08-879c-81f52429c4ef" occi.core.title="link to storage" occi.storagelink.deviceid="xvda" occi.storagelink.state="inactive" org.opennebula.storagelink.bus="ide" org.opennebula.storagelink.driver="tap2:tapdisk:aio:"|
          resource_string << %Q|\nLink: </network/e4bd81c4-adda-5626-840d-39bb7959db97>;rel="http://schemas.ogf.org/occi/infrastructure#network";self="/networkinterface/e75ab249-9325-511c-82b8-a7e4430381e3";category="http://schemas.ogf.org/occi/infrastructure#networkinterface";occi.core.id="e75ab249-9325-511c-82b8-a7e4430381e3" occi.core.title="link to network interface" occi.networkinterface.address="192.168.254.8" occi.networkinterface.mac="02:00:c0:a8:fe:08" occi.networkinterface.state="inactive" org.opennebula.networkinterface.bridge="xenbr0"|

          collection = Occi::Parser::Text.resource resource_string.lines
          collection.resources.should have(1).resource
          collection.links.should have(2).links
        end

        context '#resource' do
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
end
