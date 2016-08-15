module Occi
  module Core
    module Helpers
      describe InstanceAttributeResetter do
        subject { pristine_obj }

        let(:pristine_obj) do
          object = Object.clone.new
          object.extend(InstanceAttributeResetter)
          object
        end

        let(:base_attribute_name) { 'occi.test.attribute' }
        let(:added_attribute_name) { 'occi.test.added' }

        let(:base_attributes) do
          { base_attribute_name => instance_double('Occi::Core::AttributeDefinition') }
        end

        let(:added_attributes) do
          [{
            added_attribute_name => instance_double('Occi::Core::AttributeDefinition')
          }]
        end

        before(:example) do
          allow(subject).to receive(:base_attributes).and_return(base_attributes)
          allow(subject).to receive(:added_attributes).and_return(added_attributes)
        end

        describe '#reset_attributes!'
        describe '#reset_base_attributes!'
        describe '#reset_added_attributes!'
        describe '#reset_attributes'
        describe '#remove_undef_attributes'

        describe '#attribute_names' do
          context 'with attributes'
          context 'without attributes'
          context 'with nil attribute names'
        end

        describe '#reset_base_attributes'
        describe '#reset_added_attributes'

        describe '#reset_attribute' do
          context 'when attribute exists'
          context 'when attribute does not exist'
          context 'when `force` is used'
          context 'when `force` is not used'
        end
      end
    end
  end
end
