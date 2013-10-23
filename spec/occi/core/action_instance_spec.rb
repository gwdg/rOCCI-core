module Occi
  module Core
    describe ActionInstance do

      let(:action){ Occi::Core::Action.new }

      let(:attributes){ Occi::Core::Attributes.new }
      let(:attributes_one){
        attrs = Occi::Core::Attributes.new
        attrs["occi.core.title"] = "test"

        attrs
      }
      let(:attributes_wnil){
        attrs = Occi::Core::Attributes.new
        attrs["occi.core.title"] = nil

        attrs
      }
      let(:attributes_multi){
        attrs = Occi::Core::Attributes.new
        attrs["occi.core.title"] = "test"
        attrs["occi.core.id"] = "1"
        attrs["org.opennebula.network.id"] = 1

        attrs
      }
      let(:attributes_unconvertable){ { "not" => "convertable" } }

      let(:action_string){ 'http://rspec.rocci.cesnet.cz/occi/core#action' }
      let(:action_string_invalid){ 'http://rspec.rocci.cesnet.cz/occi/core_action' }

      context '#new' do
        it 'with defaults' do
          expect { Occi::Core::ActionInstance.new }.not_to raise_error
        end

        it 'fails without an action' do
          expect { Occi::Core::ActionInstance.new nil }.to raise_error(ArgumentError)
        end

        it 'fails without attributes' do
          expect { Occi::Core::ActionInstance.new action, nil }.to raise_error(ArgumentError)
        end

        it 'with an Occi::Core::Action instance' do
          expect { Occi::Core::ActionInstance.new action }.not_to raise_error
        end

        it 'with a valid action type identifier' do
          expect { Occi::Core::ActionInstance.new action_string }.not_to raise_error
        end

        it 'with an invalid action type identifier' do
          expect { Occi::Core::ActionInstance.new action_string_invalid }.to raise_error(ArgumentError)
        end

        it 'with an Occi::Core::Attributes instance' do
          expect { Occi::Core::ActionInstance.new action, attributes }.not_to raise_error
        end

        it 'with un-convertable attribute values' do
          expect { Occi::Core::ActionInstance.new action, attributes_unconvertable}.to raise_error(ArgumentError)
        end
      end

      context '#action' do
        it 'exposes associated action as Occi::Core::Action' do
          expect(Occi::Core::ActionInstance.new.action).to be_a(Occi::Core::Action)
        end
      end

      context '#attributes' do
        it 'exposes associated attributes as Occi::Core::Attributes' do
          expect(Occi::Core::ActionInstance.new.attributes).to be_a(Occi::Core::Attributes)
        end
      end

      context '#model' do
        # TODO: should ActionInstance have an associated model?
        it 'exposes associated model as Occi::Model (??)' #do
          #expect(Occi::Core::ActionInstance.new.model).to be_a(Occi::Model)
        #end
      end

      context '#to_text' do
        it 'renders default to text' do
          expected = "Category: action_instance;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""
          expect(Occi::Core::ActionInstance.new.to_text).to eq(expected)
        end

        it 'renders to text w/ an attribute' do
          expected = %Q|Category: action;scheme="http://schemas.ogf.org/occi/core#";class="action"
X-OCCI-Attribute: occi.core.title="test"|
          expect(Occi::Core::ActionInstance.new(action, attributes_one).to_text).to eq(expected)
        end

        it 'renders to text w/ attributes' do
          expected = %Q|Category: action;scheme="http://schemas.ogf.org/occi/core#";class="action"
X-OCCI-Attribute: occi.core.title="test"
X-OCCI-Attribute: occi.core.id="1"
X-OCCI-Attribute: org.opennebula.network.id=1|
          expect(Occi::Core::ActionInstance.new(action, attributes_multi).to_text).to eq(expected)
        end

        it 'renders to text w/ a nil attribute' do
          expected = "Category: action;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""
          expect(Occi::Core::ActionInstance.new(action, attributes_wnil).to_text).to eq(expected)
        end
      end

      context '#to_header' do
        it 'renders default to hash' do
          expected = {"Category" => "action_instance;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""}
          expect(Occi::Core::ActionInstance.new.to_header).to eq(expected)
        end

        it 'renders to hash w/ an attribute' do
          expected = {
            "Category" => "action;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\"",
            "X-OCCI-Attribute" => "occi.core.title=\"test\""
          }
          expect(Occi::Core::ActionInstance.new(action, attributes_one).to_header).to eq(expected)
        end

        it 'renders to hash w/ attributes' do
          expected = {
            "Category" => "action;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\"",
            "X-OCCI-Attribute" => "occi.core.title=\"test\",occi.core.id=\"1\",org.opennebula.network.id=1"
          }
          expect(Occi::Core::ActionInstance.new(action, attributes_multi).to_header).to eq(expected)
        end

        it 'renders to hash w/ a nil attribute' do
          expected = {"Category" => "action;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""}
          expect(Occi::Core::ActionInstance.new(action, attributes_wnil).to_header).to eq(expected)
        end
      end

      context '#to_json' do
        it 'renders default to JSON'
        it 'renders to JSON w/ an attribute'
        it 'renders to JSON w/ attributes'
        it 'renders to JSON w/ a nil attribute'
      end

      context '#as_json' do
        it 'renders default to Hashie::Mash' do
          expected = Hashie::Mash.new({"action" => "http://schemas.ogf.org/occi/core#action_instance"})
          expect(Occi::Core::ActionInstance.new.as_json).to eq(expected)
        end

        it 'renders to Hashie::Mash w/ an attribute' do
          expected = Hashie::Mash.new
          expected.action = "http://schemas.ogf.org/occi/core#action"
          expected.attributes = {"occi" => {"core" => {"title" => "test"}}}

          expect(Occi::Core::ActionInstance.new(action, attributes_one).as_json).to eq(expected)
        end

        it 'renders to Hashie::Mash w/ attributes' do
          expected = Hashie::Mash.new
          expected.action = "http://schemas.ogf.org/occi/core#action"
          expected.attributes = {
            "occi" => {"core" => {"title" => "test", "id" => "1"}},
            "org" => {"opennebula" => {"network" => {"id" => 1}}}
          }

          expect(Occi::Core::ActionInstance.new(action, attributes_multi).as_json).to eq(expected)
        end
      end

    end
  end
end