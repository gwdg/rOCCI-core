module Occi
  module Core
    module Renderers
      module Text
        describe Attributes do
          subject(:tra) { Attributes.new }

          let(:attr_def_string) do
            Occi::Core::AttributeDefinition.new
          end

          let(:attr_def_numeric) do
            Occi::Core::AttributeDefinition.new(type: Numeric)
          end

          let(:attr_def_bool) do
            Occi::Core::AttributeDefinition.new(type: TrueClass)
          end

          let(:attr_def_kind) do
            Occi::Core::AttributeDefinition.new(type: Occi::Core::Kind)
          end

          let(:attr_def_res) do
            Occi::Core::AttributeDefinition.new(type: Occi::Core::Resource)
          end

          let(:attr_def_unkn) do
            Occi::Core::AttributeDefinition.new(type: Array)
          end

          let(:attribute) do
            Occi::Core::Attribute.new(
              value: 'Text',
              attribute_definition: attr_def_string
            )
          end

          describe '#render' do
            context 'with string attribute' do
            end

            context 'with numeric attribute' do
            end

            context 'with bool attribute' do
            end

            context 'with category attribute' do
            end

            context 'with entity attribute' do
            end

            context 'with unknown attribute' do
            end
          end
        end
      end
    end
  end
end
