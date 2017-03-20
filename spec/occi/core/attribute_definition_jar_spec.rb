module Occi
  module Core
    describe AttributeDefinitionJar do
      subject(:def_jar) { attribute_definition_jar }
      let(:def_jar_class) { Occi::Core::AttributeDefinitionJar }
      let(:attribute_definition_jar) { def_jar_class.new }

      let(:example_paths) { [] }
      let(:example_attribute_definitions) { {} }
      let(:example_attr_name) { 'occi.core.id' }
      let(:example_noattr_name) { 'meh.more.maybe' }
      let(:example_attr_def) { Occi::Core::AttributeDefinition.new }

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

      describe '::new' do
        let(:attribute_definition_jar) do
          Occi::Core::AttributeDefinitionJar.new(
            paths: example_paths,
            attribute_definitions: example_attribute_definitions
          )
        end

        ATTR_ATTRS.each do |attr|
          it "assigns #{attr}" do
            expect(def_jar.send(attr)).to match send("example_#{attr}")
          end
        end

        it 'fails with `nil` paths' do
          expect { AttributeDefinitionJar.new(paths: nil) }.to raise_error(
            Occi::Core::Errors::MandatoryArgumentError
          )
        end

        it 'fails with `nil` attribute_definitions' do
          expect { AttributeDefinitionJar.new(attribute_definitions: nil) }.to raise_error(
            Occi::Core::Errors::MandatoryArgumentError
          )
        end
      end

      describe '#get' do
        it 'retrieves present definition' do
          expect(def_jar.get(example_attr_name)).to be_kind_of Occi::Core::AttributeDefinition
        end

        it 'returns `nil` for missing definition' do
          expect(def_jar.get(example_noattr_name)).to be_nil
        end
      end

      describe '#get!' do
        it 'retrieves present definition' do
          expect(def_jar.get!(example_attr_name)).to be_kind_of Occi::Core::AttributeDefinition
        end

        it 'raises error for missing definition' do
          expect { def_jar.get!(example_noattr_name) }.to raise_error(RuntimeError)
        end
      end

      describe '#put' do
        it 'stores attribute definition' do
          expect { def_jar.put(example_noattr_name, example_attr_def) }.not_to raise_error
          expect(def_jar.get(example_noattr_name)).to eq example_attr_def
        end

        it 'overwrites existing definition' do
          expect(def_jar.get(example_attr_name)).not_to eq example_attr_def
          expect { def_jar.put(example_attr_name, example_attr_def) }.not_to raise_error
          expect(def_jar.get(example_attr_name)).to eq example_attr_def
        end
      end

      describe '#put!' do
        it 'stores attribute definition' do
          expect { def_jar.put!(example_noattr_name, example_attr_def) }.not_to raise_error
          expect(def_jar.get(example_noattr_name)).to eq example_attr_def
        end

        it 'overwrites existing definition' do
          expect(def_jar.get(example_attr_name)).not_to eq example_attr_def
          expect { def_jar.put!(example_attr_name, example_attr_def) }.to raise_error(RuntimeError)
          expect(def_jar.get(example_attr_name)).not_to eq example_attr_def
        end
      end

      describe '::default_paths' do
        it 'returns list of default paths' do
          expect(def_jar_class.default_paths).to be_kind_of Array
          expect(def_jar_class.default_paths).not_to be_empty
        end
      end

      describe '#attribute_names' do
        it 'returns list of attribute names' do
          expect(def_jar.attribute_names).to be_kind_of Array
          expect(def_jar.attribute_names).not_to be_empty
        end
      end

      describe '#include?' do
        it 'returns `true` when attribute present' do
          expect(def_jar.include?(example_attr_name)).to be true
        end

        it 'returns `false` when attribute not present' do
          expect(def_jar.include?(example_noattr_name)).to be false
        end
      end

      describe '#reload!' do
        it 'drops custom definitions' do
          expect { def_jar.put(example_noattr_name, example_attr_def) }.not_to raise_error
          expect { def_jar.reload! }.not_to raise_error
          expect(def_jar.get(example_noattr_name)).to be_nil
        end

        it 'fills empty cache' do
          def_jar.attribute_definitions = {}
          expect { def_jar.reload! }.not_to raise_error
          expect(def_jar.get(example_attr_name)).to be_kind_of Occi::Core::AttributeDefinition
        end
      end
    end
  end
end
