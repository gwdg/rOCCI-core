module Occi
  module Core
    module Helpers
      describe AttributesAccessor do
        subject { obj_w_attrs }

        let(:example_attribute) { 'org.example.attribute' }
        let(:example_value) { 'text' }
        let(:obj_w_attrs) do
          object = RocciCoreSpec::ClassWAttributes.new
          object.attributes = instance_double('Hash')
          object.extend(AttributesAccessor)
        end

        describe '#[]' do
          it 'delegates to attributes' do
            expect(subject.attributes).to receive(:[]).with(example_attribute)
            subject[example_attribute]
          end
        end

        describe '#[]=' do
          it 'delegates to attributes' do
            expect(subject.attributes).to receive(:[]=).with(example_attribute, example_value)
            subject[example_attribute] = example_value
          end
        end
      end
    end
  end
end
