# encoding: UTF-8

module Occi
  module Parser
    describe Text do

      describe '.category' do

        it 'parses a string with an OCCI Category to an OCCI Category' do
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

        it 'parses a string with an OCCI Resource including inline OCCI Link definitions and OCCI Mixins' do
          resource_string = %Q|Category: compute; scheme="http://schemas.ogf.org/occi/infrastructure#"; class="kind"; title="Compute Resource"; rel="http://schemas.ogf.org/occi/core#resource"; location="https://egi-cloud.zam.kfa-juelich.de:8787/compute/"; attributes="occi.compute.architecture occi.compute.state{immutable} occi.compute.speed occi.compute.memory occi.compute.cores occi.compute.hostname"; actions="http://schemas.ogf.org/occi/infrastructure/compute/action#start http://schemas.ogf.org/occi/infrastructure/compute/action#stop http://schemas.ogf.org/occi/infrastructure/compute/action#restart http://schemas.ogf.org/occi/infrastructure/compute/action#suspend"
Category: os_vms; scheme="http://schemas.openstack.org/compute/instance#"; class="mixin"; location="https://egi-cloud.zam.kfa-juelich.de:8787/os_vms/"; attributes="org.openstack.compute.console.vnc{immutable} org.openstack.compute.state{immutable}"; actions="http://schemas.openstack.org/instance/action#chg_pwd http://schemas.openstack.org/instance/action#create_image"
Link: </compute/04106bce-87eb-4f8f-a665-2f624e54ba46?action=stop>; rel="http://schemas.ogf.org/occi/infrastructure/compute/action#stop"
Link: </compute/04106bce-87eb-4f8f-a665-2f624e54ba46?action=suspend>; rel="http://schemas.ogf.org/occi/infrastructure/compute/action#suspend"
Link: </compute/04106bce-87eb-4f8f-a665-2f624e54ba46?action=restart>; rel="http://schemas.ogf.org/occi/infrastructure/compute/action#restart"
Link: </network/public>; rel="http://schemas.ogf.org/occi/infrastructure#network"; self="/network/interface/6a7a9446-a146-4faf-a961-52f66d2808df"; category="http://schemas.ogf.org/occi/infrastructure#networkinterface http://schemas.ogf.org/occi/infrastructure/networkinterface#ipnetworkinterface"; occi.networkinterface.gateway="0.0.0.0"; occi.networkinterface.mac="aa:bb:cc:dd:ee:ff"; occi.networkinterface.interface="eth0"; occi.networkinterface.state="active"; occi.networkinterface.allocation="static"; occi.networkinterface.address="134.94.32.154"; occi.core.source="/compute/04106bce-87eb-4f8f-a665-2f624e54ba46"; occi.core.target="/network/public"; occi.core.id="/network/interface/6a7a9446-a146-4faf-a961-52f66d2808df"
Link: </network/admin>; rel="http://schemas.ogf.org/occi/infrastructure#network"; self="/network/interface/02b630f6-087e-4969-b04c-1e22d9480dec"; category="http://schemas.ogf.org/occi/infrastructure#networkinterface http://schemas.ogf.org/occi/infrastructure/networkinterface#ipnetworkinterface"; occi.networkinterface.gateway="192.168.16.1"; occi.networkinterface.mac="fa:16:3e:45:1c:26"; occi.networkinterface.interface="eth0"; occi.networkinterface.state="active"; occi.networkinterface.allocation="static"; occi.networkinterface.address="192.168.16.103"; occi.core.source="/compute/04106bce-87eb-4f8f-a665-2f624e54ba46"; occi.core.target="/network/admin"; occi.core.id="/network/interface/02b630f6-087e-4969-b04c-1e22d9480dec"
X-OCCI-Attribute: org.openstack.compute.console.vnc="http://134.94.32.4:6080/vnc_auto.html?token=9923dc1b-eca0-4c62-81a8-a0dd6848341a"
X-OCCI-Attribute: occi.compute.architecture="x86"
X-OCCI-Attribute: occi.compute.state="active"
X-OCCI-Attribute: occi.compute.speed="0.0"
X-OCCI-Attribute: occi.compute.cores="1"
X-OCCI-Attribute: occi.compute.memory="1.0"
X-OCCI-Attribute: org.openstack.compute.state="active"
X-OCCI-Attribute: occi.compute.hostname="openmodeller-test-bjoernh"
X-OCCI-Attribute: occi.core.id="04106bce-87eb-4f8f-a665-2f624e54ba46"|

          collection = Occi::Parser::Text.resource resource_string.lines
          collection.resources.should have(1).resource
          collection.links.should have(5).links
        end

      end

    end
  end
end
