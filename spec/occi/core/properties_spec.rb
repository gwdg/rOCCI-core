module Occi
  module Core
    describe Properties do

      context '#type=' do
        let(:properties){ Occi::Core::Properties.new }
        it 'accepts string' do
          expect{ properties.type = 'string' }.to_not raise_exception
        end

        it 'accepts number' do
          expect{ properties.type = 'number' }.to_not raise_exception
        end

        it 'accepts boolean' do
          expect{ properties.type = 'boolean' }.to_not raise_exception
        end

        it 'rejects another string' do
          expect{ properties.type = 'other' }.to raise_exception Occi::Errors::AttributePropertyTypeError
        end

      end

      context '#check_value_for_type' do
        context 'string' do
          let(:properties){ properties = Occi::Core::Properties.new
            properties.type = 'string'
            properties }

          it 'permits string' do
            expect{ properties.check_value_for_type("string") }.to_not raise_exception
          end

          it 'rejects nil' do
            expect{ properties.check_value_for_type(nil) }.to raise_exception(Occi::Errors::AttributeTypeError)
          end

          it 'rejects another class' do
            expect{ properties.check_value_for_type(true) }.to raise_exception(Occi::Errors::AttributeTypeError)
          end
        end

        context 'number' do
          let(:properties){ properties = Occi::Core::Properties.new
            properties.type = 'number'
            properties }

          it 'permits number' do
            expect{ properties.check_value_for_type(42) }.to_not raise_exception
          end

          it 'rejects nil' do
            expect{ properties.check_value_for_type(nil) }.to raise_exception(Occi::Errors::AttributeTypeError)
          end

          it 'rejects another class' do
            expect{ properties.check_value_for_type("string") }.to raise_exception(Occi::Errors::AttributeTypeError)
          end
        end

        context 'boolean' do
          let(:properties){ properties = Occi::Core::Properties.new
            properties.type = 'boolean'
            properties }

          it 'permits true' do
            expect{ properties.check_value_for_type(true) }.to_not raise_exception
          end

          it 'permits false' do
            expect{ properties.check_value_for_type(false) }.to_not raise_exception
          end

          it 'rejects nil' do
            expect{ properties.check_value_for_type(nil) }.to raise_exception(Occi::Errors::AttributeTypeError)
          end

          it 'rejects another class' do
            expect{ properties.check_value_for_type(0) }.to raise_exception(Occi::Errors::AttributeTypeError)
          end
        end
      end

      context 'rendering' do
        let(:properties) { properties = Occi::Core::Properties.new
          properties.type = "string"
          properties.required = true
          properties.mutable = true
          properties.default = "defaultvalue"
          properties.description = "Required string value"
          properties.pattern = "[adefltuv]+"
          properties }

        context '#to_hash' do
          it 'makes a correct rendering' do
            expected = Hash.new

            expected["default"] = "defaultvalue"
            expected["description"] = "Required string value"
            expected["mutable"] = true
            expected["pattern"] = "[adefltuv]+"
            expected["required"] = true
            expected["type"] = "string"

            expect(properties.to_hash).to eql expected
          end
        end

        context '#as_json' do
          it 'makes a correct rendering' do
            expected = Hash.new

            expected["default"] = "defaultvalue"
            expected["description"] = "Required string value"
            expected["mutable"] = true
            expected["pattern"] = "[adefltuv]+"
            expected["required"] = true
            expected["type"] = "string"

            expect(properties.to_hash).to eql expected
          end

          it 'makes a correct rendering of empty props' do
            empty = Occi::Core::Properties.new
            expected = Hash.new
            expected["mutable"] = true
            expected["pattern"] = ".*"
            expected["required"] = false
            expected["type"] = "string"

            expect(empty.to_hash).to eql expected
          end

        end

        context '#to_json' do
          it 'makes a correct rendering' do
            expected = '{"default":"defaultvalue","type":"string","required":true,"mutable":true,"pattern":"[adefltuv]+","description":"Required string value"}'
            expect(properties.to_json).to eql expected
          end
        end
      end

      context '#empty?' do
        let(:properties) { properties = Occi::Core::Properties.new
          properties.type = "string"
          properties.required = true
          properties.mutable = true
          properties.default = "defaultvalue"
          properties.description = "Required string value"
          properties.pattern = "[adefltuv]+"
          properties }

        it 'Returns false for non-empty props' do
          expect(properties.empty?).to be false
        end

        it 'Returns true for empty props' do
          empty = Occi::Core::Properties.new
          empty.mutable = nil
          empty.pattern = nil
          empty.required = nil
          empty.instance_eval { @type=nil }

          expect(empty.empty?).to be true
        end
      end
    end
  end
end
