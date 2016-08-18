module Occi
  module Core
    module Helpers
      describe InstanceAttributesAccessor do
        subject(:object_with_attributes) { obj_w_attrs }

        let(:example_attribute) { 'org.example.attribute' }
        let(:example_value) { 'text' }
        let(:obj_w_attrs) do
          object = RocciCoreSpec::ClassWAttributes.clone.new
          object.attributes = {}
          object.attributes[example_attribute] = instance_double('Occi::Core::Attribute')
          object.extend(InstanceAttributesAccessor)
          object
        end

        describe '#[]' do
          it 'delegates to attribute value' do
            expect(object_with_attributes.attributes[example_attribute]).to receive(:value)
            object_with_attributes[example_attribute]
          end

          it 'returns `nil` for non-existent attribute' do
            expect(object_with_attributes['meeh.meh']).to be nil
          end
        end

        describe '#[]=' do
          it 'delegates to attribute value assignment' do
            expect(object_with_attributes.attributes[example_attribute]).to receive(:value=).with(example_value)
            object_with_attributes[example_attribute] = example_value
          end

          it 'raises error for non-existent attribute' do
            expect do
              object_with_attributes['meeh.meh'] = example_value
            end.to raise_error(Occi::Core::Errors::AttributeDefinitionError)
          end
        end

        describe '#attribute?' do
          it 'returns `true` when attribute is defined and not `nil`' do
            expect(object_with_attributes.attribute?(example_attribute)).to be true
          end

          it 'returns `false` when attribute is not defined' do
            expect(object_with_attributes.attribute?('meeh.meh')).to be false
          end

          it 'returns `false` when attribute is `nil`' do
            object_with_attributes.attributes['test'] = nil
            expect(object_with_attributes.attribute?('test')).to be false
          end
        end
      end
    end
  end
end
