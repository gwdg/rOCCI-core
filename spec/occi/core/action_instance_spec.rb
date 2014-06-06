module Occi
  module Core
    describe ActionInstance do

      let(:ai){ Occi::Core::ActionInstance.new }
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
          expect { ai }.not_to raise_error
        end

        it 'fails without an action' do
          expect { Occi::Core::ActionInstance.new nil }.to raise_error(ArgumentError)
        end

        it 'does not fail without attributes' do
          expect { Occi::Core::ActionInstance.new action, nil }.not_to raise_error
        end

        it 'does not fail with an Occi::Core::Action instance' do
          expect { Occi::Core::ActionInstance.new action }.not_to raise_error
        end

        it 'does not fail with a valid action type identifier' do
          expect { Occi::Core::ActionInstance.new action_string }.not_to raise_error
        end

        it 'fails with an invalid action type identifier' do
          expect { Occi::Core::ActionInstance.new action_string_invalid }.to raise_error(ArgumentError)
        end

        it 'does not fail with an Occi::Core::Attributes instance' do
          expect { Occi::Core::ActionInstance.new action, attributes }.not_to raise_error
        end

        it 'does not fail with un-convertable attribute values' do
          expect { Occi::Core::ActionInstance.new action, attributes_unconvertable}.not_to raise_error
        end
      end

      context '#action' do
        it 'exposes associated action as Occi::Core::Action' do
          expect(ai.action).to be_a(Occi::Core::Action)
        end
      end

      context '#attributes' do
        it 'exposes associated attributes as Occi::Core::Attributes' do
          expect(ai.attributes).to be_a(Occi::Core::Attributes)
        end
      end

      context '#model' do
        # TODO: should ActionInstance have an associated model?
        it 'exposes associated model as Occi::Model (??)' #do
          #expect(ai.model).to be_a(Occi::Model)
        #end
      end

      context '#to_text' do
        it 'renders default to text' do
          expected = "Category: action_instance;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""
          expect(ai.to_text).to eq(expected)
        end

        it 'renders to text w/ an attribute' do
          expected = %Q|Category: action;scheme="http://schemas.ogf.org/occi/core#";class="action"
X-OCCI-Attribute: occi.core.title="test"|
          expect(Occi::Core::ActionInstance.new(action, attributes_one.to_hash).to_text).to eq(expected)
        end

        it 'renders to text w/ attributes' do
          expected = %Q|Category: action;scheme="http://schemas.ogf.org/occi/core#";class="action"
X-OCCI-Attribute: occi.core.title="test"
X-OCCI-Attribute: occi.core.id="1"
X-OCCI-Attribute: org.opennebula.network.id=1|
          expect(Occi::Core::ActionInstance.new(action, attributes_multi.to_hash).to_text).to eq(expected)
        end

        it 'renders to text w/ a nil attribute' do
          expected = "Category: action;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""
          expect(Occi::Core::ActionInstance.new(action, attributes_wnil.to_hash).to_text).to eq(expected)
        end
      end

      context '#to_header' do
        it 'renders default to hash' do
          expected = {"Category" => "action_instance;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""}
          expect(ai.to_header).to eq(expected)
        end

        it 'renders to hash w/ an attribute' do
          expected = {
            "Category" => "action;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\"",
            "X-OCCI-Attribute" => "occi.core.title=\"test\""
          }
          expect(Occi::Core::ActionInstance.new(action, attributes_one.to_hash).to_header).to eq(expected)
        end

        it 'renders to hash w/ attributes' do
          expected = {
            "Category" => "action;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\"",
            "X-OCCI-Attribute" => "occi.core.title=\"test\",occi.core.id=\"1\",org.opennebula.network.id=1"
          }
          expect(Occi::Core::ActionInstance.new(action, attributes_multi.to_hash).to_header).to eq(expected)
        end

        it 'renders to hash w/ a nil attribute' do
          expected = {"Category" => "action;scheme=\"http://schemas.ogf.org/occi/core#\";class=\"action\""}
          expect(Occi::Core::ActionInstance.new(action, attributes_wnil.to_hash).to_header).to eq(expected)
        end
      end

      context '#to_json' do
        let(:actioninstance){ Occi::Core::ActionInstance.new }
        it 'renders default to JSON' do
          expected = '{"action":"http://schemas.ogf.org/occi/core#action_instance","attributes":{}}'
          expect(actioninstance.to_json).to eql expected
        end

        it 'renders to JSON w/ an attribute' do
          actioninstance.attributes.testattr = 'test'
          expected = '{"action":"http://schemas.ogf.org/occi/core#action_instance","attributes":{"testattr":"test"}}'
          expect(actioninstance.to_json).to eql expected
        end

        it 'renders to JSON w/ multiple attributes' do
          actioninstance.attributes.testattr = 'test'
          actioninstance.attributes.anotherattr = 42
          expected = '{"action":"http://schemas.ogf.org/occi/core#action_instance","attributes":{"testattr":"test","anotherattr":42}}'
          expect(actioninstance.to_json).to eql expected
        end

        it 'renders to JSON w/ a nil attribute' do
          actioninstance.attributes.testattr = nil
          expected = '{"action":"http://schemas.ogf.org/occi/core#action_instance","attributes":{}}'
          expect(actioninstance.to_json).to eql expected
        end
      end

      context '#as_json' do
        it 'renders default to Hashie::Mash' do
          expected = Hashie::Mash.new({"action" => "http://schemas.ogf.org/occi/core#action_instance", "attributes" => {}})
          expect(ai.as_json).to eq(expected)
        end

        it 'renders to Hashie::Mash w/ an attribute' do
          expected = Hashie::Mash.new
          expected.action = "http://schemas.ogf.org/occi/core#action"
          expected.attributes = {"occi" => {"core" => {"title" => "test"}}}

          expect(Occi::Core::ActionInstance.new(action, attributes_one.to_hash).as_json).to eq(expected)
        end

        it 'renders to Hashie::Mash w/ attributes' do
          expected = Hashie::Mash.new
          expected.action = "http://schemas.ogf.org/occi/core#action"
          expected.attributes = {
            "occi" => {"core" => {"title" => "test", "id" => "1"}},
            "org" => {"opennebula" => {"network" => {"id" => 1}}}
          }

          expect(Occi::Core::ActionInstance.new(action, attributes_multi.to_hash).as_json).to eq(expected)
        end
      end

      context '#==' do

        it 'matches the same instance' do
          expect(ai).to eq ai
        end

        it 'matches a clone' do
          expect(ai).to eq ai.clone
        end

        it 'does not match with a different action' do
          changed = ai.clone
          changed.action = Occi::Core::Action.new(action_string)

          expect(ai).not_to eq changed
        end

        it 'does not match with different attributes' do
          changed = ai.clone
          changed.attributes = attributes_one

          expect(ai).not_to eq changed
        end

        it 'does not match a nil' do
          expect(ai).not_to eq nil
        end

      end

      context '#eql?' do

        it 'matches the same instance' do
          expect(ai).to eql ai
        end

        it 'matches a clone' do
          expect(ai).to eql ai.clone
        end

        it 'does not match with a different action' do
          changed = ai.clone
          changed.action = Occi::Core::Action.new(action_string)

          expect(ai).not_to eql changed
        end

        it 'does not match with different attributes' do
          changed = ai.clone
          changed.attributes = attributes_one

          expect(ai).not_to eql changed
        end

        it 'does not match a nil' do
          expect(ai).not_to eql nil
        end

      end

      context '#equal?' do

        it 'matches the same instance' do
          expect(ai).to equal ai
        end

        it 'does not match clones' do
          expect(ai).not_to equal ai.clone
        end

      end

      context '#hash' do

        it 'matches for clones' do
          expect(ai.hash).to eq ai.clone.hash
        end

        it 'matches for the same instance' do
          expect(ai.hash).to eq ai.hash
        end

        it 'does not match when action is different' do
          ai_changed = ai.clone
          ai_changed.action = Occi::Core::Action.new action_string

          expect(ai.hash).not_to eq ai_changed.hash
        end

        it 'does not match when attributes are different' do
          ai_changed = ai.clone
          ai_changed.attributes = attributes_one

          expect(ai.hash).not_to eq ai_changed.hash
        end

      end

      context '#empty?' do

        it 'returns false for a new instance with defaults' do
          expect(ai.empty?).to be false
        end

        it 'returns true for an instance without an action' do
          ai_changed = ai.clone
          ai_changed.action = nil

          expect(ai_changed.empty?).to be true
        end

        it 'returns true for an instance with an empty action' do
          ai_changed = ai.clone
          ai_changed.action = Occi::Core::Action.new
          ai_changed.action.term = nil

          expect(ai_changed.empty?).to be true
        end

      end

    end
  end
end
