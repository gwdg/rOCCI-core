module Occi
  module Core
    module Helpers
      describe InstanceAttributeResetter do
        subject { obj_w_attrs }

        let(:example_attribute) { 'org.example.attribute' }
        let(:example_value) { 'text' }
        let(:obj_w_attrs) do
          object = RocciCoreSpec::ClassWAttributes.clone.new
          object.attributes = instance_double('Hash')
          object.extend(InstanceAttributeResetter)
          object.class.send(:define_method, 'base_attributes', proc { {} })
          object.class.send(:define_method, 'added_attributes', proc { [] })
          object
        end
        let(:pristine_obj) do
          object = Object.clone.new
          object.extend(InstanceAttributeResetter)
          object
        end
      end
    end
  end
end
