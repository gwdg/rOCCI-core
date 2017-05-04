module Occi
  module Core
    module Helpers
      describe AttributesAccessor do
        subject(:object_with_attributes) { obj_w_attrs }

        let(:example_attribute) { 'org.example.attribute' }
        let(:example_value) { 'text' }
        let(:obj_w_attrs) do
          object = RocciCoreSpec::ClassWAttributes.clone.new
          object.attributes = instance_double('Hash')
          object.extend(AttributesAccessor)
        end

        describe '#[]' do
          it 'delegates to attributes' do
            expect(object_with_attributes.attributes).to receive(:[]).with(example_attribute)
            object_with_attributes[example_attribute]
          end
        end

        describe '#[]=' do
          it 'delegates to attributes' do
            expect(object_with_attributes.attributes).to receive(:[]=).with(example_attribute, example_value)
            object_with_attributes[example_attribute] = example_value
          end
        end
      end
    end
  end
end
