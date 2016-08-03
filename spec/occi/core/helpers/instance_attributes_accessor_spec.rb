module Occi
  module Core
    module Helpers
      describe InstanceAttributesAccessor do
        subject { obj_w_attrs }

        let(:example_attribute) { 'org.example.attribute' }
        let(:example_value) { 'text' }
        let(:obj_w_attrs) do
          object = RocciCoreSpec::ClassWAttributes.new
          object.attributes = {}
          object.attributes[example_attribute] = instance_double('Occi::Core::Attribute')
          object.extend(InstanceAttributesAccessor)
          object
        end

        describe '#[]' do
          it 'delegates to attribute value' do
            expect(subject.attributes[example_attribute]).to receive(:value)
            subject[example_attribute]
          end

          it 'returns `nil` for non-existent attribute' do
            expect(subject['meeh.meh']).to be nil
          end
        end

        describe '#[]=' do
          it 'delegates to attribute value assignment' do
            expect(subject.attributes[example_attribute]).to receive(:value=).with(example_value)
            subject[example_attribute] = example_value
          end

          it 'raises error for non-existent attribute' do
            expect { subject['meeh.meh'] = example_value }.to raise_error(Occi::Core::Errors::AttributeDefinitionError)
          end
        end

        describe '#attribute?' do
          it 'returns `true` when attribute is defined and not `nil`' do
            expect(subject.attribute?(example_attribute)).to be true
          end

          it 'returns `false` when attribute is not defined' do
            expect(subject.attribute?('meeh.meh')).to be false
          end

          it 'returns `false` when attribute is `nil`' do
            subject.attributes['test'] = nil
            expect(subject.attribute?('test')).to be false
          end
        end
      end
    end
  end
end
