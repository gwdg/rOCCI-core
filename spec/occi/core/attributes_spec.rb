module Occi
  module Core
    describe Attributes do

      context '#[]=' do
        it 'stores properties using hashes in hash notation'  do
          attributes=Occi::Core::Attributes.new
          attributes['test']={}
          
          expect(attributes['test']).to be_kind_of Occi::Core::Properties
        end

        it 'stores properties using hashes in dot notation'  do
          attributes=Occi::Core::Attributes.new
          attributes.test={}

          expect(attributes.test).to be_kind_of Occi::Core::Properties
        end
      end

      context '#remove' do
        it 'removes attributes' do
          attributes=Occi::Core::Attributes.new
          attributes['one.two']={}
          attributes['one.three']={}

          attr=Occi::Core::Attributes.new
          attr['one.two']={}
          attributes.remove attr

          expect(attributes['one.two']).to be_nil
          expect(attributes['one.three']).to be_kind_of Occi::Core::Properties
        end
      end

      context '#convert' do
        it 'converts properties to an empty attribute' do
          attributes=Occi::Core::Attributes.new
          attributes.test={}

          attr = attributes.convert
          expect(attributes.test).to be_kind_of Occi::Core::Properties

          expect(attr.test).to be_nil
          expect(attr._test).to be_kind_of Occi::Core::Properties

          attributes.convert!
          expect(attributes.test).to be_nil
          expect(attributes._test).to be_kind_of Occi::Core::Properties
        end
      end

      context 'comparators' do
        let(:attrs){
          attrs = Occi::Core::Attributes.new
            attrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
            attrs['stringtype'] = { :type => 'string', :pattern => '[adefltuv]+', :default => 'defaultvalue', :mutable => true }
            attrs['booleantype'] = { :type => 'boolean', :default => true, :mutable => true}
            attrs['booleantypefalse'] = { :type => 'boolean', :default => false, :mutable => true }
            attrs['booleantypepattern'] = { :type => 'boolean', :default => true, :mutable => true, :pattern => true }
          attrs }
        let(:clone){ clone = attrs.clone }
        let(:newattrs){
          newattrs = Occi::Core::Attributes.new
            newattrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
            newattrs['stringtype'] = { :type => 'string', :pattern => '[adefltuv]+', :default => 'defaultvalue', :mutable => true }
            newattrs['booleantype'] = { :type => 'boolean', :default => true, :mutable => true}
            newattrs['booleantypefalse'] = { :type => 'boolean', :default => false, :mutable => true }
            newattrs['booleantypepattern'] = { :type => 'boolean', :default => true, :mutable => true, :pattern => true }
          newattrs }
        let(:diffattrs){
          diffattrs = Occi::Core::Attributes.new
            diffattrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
            diffattrs['stringtype'] = { :type => 'string', :pattern => '[adefltuv]+', :default => 'anothervalue', :mutable => true } # <=
            diffattrs['booleantype'] = { :type => 'boolean', :default => true, :mutable => true}
            diffattrs['booleantypefalse'] = { :type => 'boolean', :default => false, :mutable => true }
            diffattrs['booleantypepattern'] = { :type => 'boolean', :default => true, :mutable => true, :pattern => true }
          diffattrs }

        context '#==' do
          it 'matches the same instance' do
            expect(attrs==attrs).to eql true
          end

          it 'matches a clone' do
            expect(attrs==clone).to eql true
          end
    
          it 'matches a new instance with the same content' do
            expect(attrs==newattrs).to eql true
          end

          it 'does not match nil' do
            expect(attrs==nil).to eql false
          end

          it 'does not match an instance with different content' do
            expect(attrs==diffattrs).to eql false
          end
        end

        context '#eql?' do
          it 'matches the same instance' do
            expect(attrs.eql?(attrs)).to eql true
          end

          it 'matches a clone' do
            expect(attrs.eql?(clone)).to eql true
          end
    
          it 'matches a new instance with the same content' do
            expect(attrs.eql?(newattrs)).to eql true
          end

          it 'does not match nil' do
            expect(attrs.eql?(nil)).to eql false
          end

          it 'does not match an instance with different content' do
            expect(attrs.eql?(diffattrs)).to eql false
          end
        end

        context '#equal?' do
          it 'matches the same instance' do
            expect(attrs.equal?(attrs)).to eql true
          end

          it 'does not match a clone' do
            expect(attrs.equal?(clone)).to eql false
          end
        end

        context '#hash' do
          it 'matches for the same instance' do
            expect(attrs.hash).to eql attrs.hash
          end

          it 'matches for a clone' do
            expect(attrs.hash).to eql clone.hash
          end

          it 'matches for a new instance with the same content' do
            expect(attrs.hash).to eql newattrs.hash
          end

          it 'does not match for an instance with different content' do
            expect(attrs.hash).to_not eql diffattrs.hash
          end
        end
      end

      context '#converted?' do
        let(:attrs){ attrs = Occi::Core::Attributes.new
          attrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
          attrs }

        it 'correctly reports uncoverted' do
          expect(attrs.converted?).to eql false
        end

        it 'correctly reports coverted' do
          expect(attrs.convert.converted?).to eql true
        end
      end


      context 'rendering' do
        let(:attrs){ attrs = Occi::Core::Attributes.new 
          attrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
          attrs['stringtype'] = { :type => 'string', :pattern => '[adefltuv]+', :default => 'defaultvalue', :mutable => true }
          attrs['booleantype'] = { :type => 'boolean', :default => true, :mutable => true}
          attrs['booleantypefalse'] = { :type => 'boolean', :default => false, :mutable => true }
          attrs['booleantypepattern'] = { :type => 'boolean', :default => true, :mutable => true, :pattern => true }
          attrs.nest!.nested = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
          attrs['properties'] = Occi::Core::Properties.new
          attrs.convert
          attrs['numbertype'] = 42
          attrs['stringtype'] = 'flute'
          attrs['booleantype'] = true
          attrs['booleantypefalse'] = false
          attrs['booleantypepattern'] = true
          attrs.nest!.nested = 11
          attrs['category'] = Occi::Core::Category.new
          attrs['properties'] = "prop"
          attrs }
        let(:empty){ Occi::Core::Attributes.new.convert }

        context '.parse_properties' do

          it 'rejects unsuitable types' do
            string = String.new("Teststring")
            expect{ Occi::Core::Attributes.parse_properties(string) }.to raise_error(Occi::Errors::ParserInputError)
          end

          it 'parses a hashie Mash' do
            hash = Hashie::Mash.new
            hash.nr!.type = 'number'
            hash.nr!.default = 42
            hash.nr!.mutable = true

            expected = Occi::Core::Attributes.new
            expected['nr'] = { :type => 'number', :default => 42, :mutable => true }
            expected.convert

            attrs = Occi::Core::Attributes.parse_properties(hash)
            attrs.convert

            expect(attrs).to eql expected
          end
        end

        context '#to_string' do
          it 'renders attributes correctly' do
            expected = ";numbertype=42;stringtype=\"flute\";booleantype=true;booleantypefalse=false;booleantypepattern=true;nest.nested=11;properties=\"prop\";category=\"http://schemas.ogf.org/occi/core#category\""
            expect(attrs.to_string).to eql expected
          end

          it 'copes with empty attributes' do
            expected = ""
            expect(empty.to_string).to eql expected
          end
        end

        context '#to_string_short' do
          it 'renders attributes correctly' do
            expected = ";attributes=\"numbertype stringtype booleantype booleantypefalse booleantypepattern nest.nested properties category\""
            expect(attrs.to_string_short).to eql expected
          end

          it 'copes with empty attributes' do
            expected = ""
            expect(empty.to_string_short).to eql expected
          end
        end

        context '#to_text' do
          it 'renders attributes correctly' do
            expected = "\nX-OCCI-Attribute: numbertype=42\nX-OCCI-Attribute: stringtype=\"flute\"\nX-OCCI-Attribute: booleantype=true\nX-OCCI-Attribute: booleantypefalse=false\nX-OCCI-Attribute: booleantypepattern=true\nX-OCCI-Attribute: nest.nested=11\nX-OCCI-Attribute: properties=\"prop\"\nX-OCCI-Attribute: category={\n  \"scheme\": \"http://schemas.ogf.org/occi/core#\",\n  \"term\": \"category\",\n  \"attributes\": {\n  }\n}"
            expect(attrs.to_text).to eql expected
          end

          it 'copes with empty attributes' do
            expected = ""
            expect(empty.to_text).to eql expected
          end
        end

        context '#to_header' do
          it 'renders attributes correctly' do
            expected = "numbertype=42,stringtype=\"flute\",booleantype=true,booleantypefalse=false,booleantypepattern=true,nest.nested=11,properties=\"prop\",category=\"http://schemas.ogf.org/occi/core#category\""
            expect(attrs.to_header).to eql expected
          end

          it 'copes with empty attributes' do
            expected = ""
            expect(empty.to_header).to eql expected
          end
        end

        context '#to_json' do
          it 'renders attributes correctly' do
            expected = '{"numbertype":42,"stringtype":"flute","booleantype":true,"booleantypefalse":false,"booleantypepattern":true,"nest":{"nested":11},"properties":"prop","category":"http://schemas.ogf.org/occi/core#category"}'
            expect(attrs.to_json).to eql expected
          end

          it 'copes with empty attributes' do
            expected = "{}"
            expect(empty.to_json).to eql expected
          end
        end

        context '#as_json' do
          it 'renders attributes correctly' do
            expected = Hashie::Mash.new
            expected["booleantype"] = true
            expected["booleantypepattern"] = true
            expected["numbertype"] = 42
            expected["stringtype"] = "flute"
            expected["booleantypefalse"] = false
            expected.nest!.nested = 11
            expected["category"] = "http://schemas.ogf.org/occi/core#category"
            expected["properties"] = "prop"

            expect(attrs.as_json).to eql expected
          end

          it 'copes with empty attributes' do
            expected = Hashie::Mash.new
            expect(empty.as_json).to eql expected
          end
        end
      end

      context '.validate_and_assign' do
        let(:attrs){ Occi::Core::Attributes.new }

        it 'correctly accepts Occi::Core::Attributes' do
          inattrs = Occi::Core::Attributes.new
          inattrs['numbertype'] = { :type => 'number', :default => 42, :mutable => true, :pattern => '^[0-9]+' }
          inattrs.convert
          inattrs['numbertype'] = 13

          attrs['numbertype'] = inattrs['numbertype']
          expect(attrs).to eql inattrs
        end
  
        it 'correctly accepts Occi::Core::Properties' do
          attrs['properties'] = Occi::Core::Properties.new

          expected = Occi::Core::Attributes.new
          expected['properties'] = { :type => 'string', :pattern => '.*', :mutable => false, :required => false }
          expected.convert

          expect(attrs).to eql expected
        end
          
        it 'correctly accepts Hash' do
          attrs['hash'] = { :type => 'string', :pattern => '.*', :mutable => false, :required => false }

          expected = Occi::Core::Attributes.new
          expected['hash'] = { :type => 'string', :pattern => '.*', :mutable => false, :required => false }
          expected.convert

          expect(attrs).to eql expected
        end

        it 'correctly accepts Occi::Core::Entity' do
          entity = Occi::Core::Entity.new
          attrs['entity'] = entity

          expect(attrs['entity']).to eql entity
        end

        it 'correctly accepts Occi::Core::Category' do
          category = Occi::Core::Category.new
          attrs['category'] = category

          expect(attrs['category']).to eql category
        end

        it 'correctly accepts String' do
          attrs['string'] = "teststring"
          expect(attrs['string']).to eql "teststring"
        end

        it 'correctly accepts Numeric' do
          attrs['numeric'] = 16
          expect(attrs['numeric']).to eql 16
        end

        it 'correctly accepts TrueClass' do
          attrs['tr'] = true
          expect(attrs['tr']).to eql true
        end

        it 'correctly accepts FalseClass' do
          attrs['fal'] = false
          expect(attrs['fal']).to eql false
        end

        it 'correctly responds to NilClass' do
          attrs['nil'] = nil
          expect(attrs['nil']).to eql nil
        end

        it 'rejects unsupported types' do
          type = Occi::Log.new(nil)
          expect{ attrs['log'] = type }.to raise_error(Occi::Errors::AttributeTypeError)
        end
      end
    end
  end
end
