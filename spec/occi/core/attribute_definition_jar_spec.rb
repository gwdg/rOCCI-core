module Occi
  module Core
    describe AttributeDefinitionJar do
      subject(:def_jar) { attribute_definition_jar }
      let(:attribute_definition_jar) { Occi::Core::AttributeDefinitionJar.new }

      ATTR_ATTRS = [:paths, :attribute_definitions].freeze
      ATTR_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has logger' do
        expect(def_jar).to respond_to(:logger)
        expect(def_jar.class).to respond_to(:logger)
      end
    end
  end
end
