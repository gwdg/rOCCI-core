module Occi
  module Core
    module Parsers
      module Text
        describe Category do
          subject(:cat) { Category }

          it 'has logger' do
            expect(cat).to respond_to(:logger)
          end

          describe '::first_or_die' do
            let(:first) { instance_double(Occi::Core::Category) }
            let(:second) { instance_double(Occi::Core::Category) }
            let(:ary) { [first, second] }
            let(:identifier) { 'http://localhost/test/cat#one' }
            let(:noid) { 'nope' }

            it 'finds element identified by `what`' do
              expect(first).to receive(:identifier).and_return(noid)
              expect(second).to receive(:identifier).and_return(identifier)
              expect(cat.first_or_die(ary, identifier)).to be second
            end

            it 'returns only first matching element' do
              expect(first).to receive(:identifier).and_return(identifier)
              expect(cat.first_or_die(ary, identifier)).to be first
            end

            it 'raises error when nothing is found' do
              expect(first).to receive(:identifier).and_return(noid)
              expect(second).to receive(:identifier).and_return(noid)
              expect { cat.first_or_die(ary, identifier) }.to raise_error(Occi::Core::Errors::ParsingError)
            end
          end

          describe '::matchdata_to_hash' do
            let(:md) { instance_double(MatchData) }
            let(:group) { 'test_group' }
            let(:group_val) { 'meh' }
            let(:groups) { [group] }

            it 'converts given MatchData to a hash' do
              allow(md).to receive(:names).and_return(groups)
              allow(md).to receive(:[]).with(group).and_return(group_val)
              expect(cat.matchdata_to_hash(md)).to be_kind_of(Hash)
              expect(cat.matchdata_to_hash(md)[:test_group]).to eq group_val
            end
          end

          describe '::lookup_depends_references!' do
            it 'does something'
          end

          describe '::lookup_applies_references!' do
            it 'does something'
          end

          describe '::lookup_parent_references!' do
            it 'does something'
          end

          describe '::lookup_action_references!' do
            it 'does something'
          end

          describe '::lookup_references!' do
            it 'does something'
          end

          describe '::construct_instance' do
            it 'does something'
          end

          describe '::dereference_identifiers!' do
            it 'does something'
          end

          describe '::plain_identifiers' do
            let(:no_id_line) { '' }
            let(:id_line) { 'http://localhost/test/m#c' }
            let(:multi_id_line) { 'http://localhost/test/m#c http://test/fadf/v#r' }

            it 'returns empty list for empty input' do
              expect(cat.plain_identifiers(no_id_line)).to be_empty
            end

            it 'return one item for one item input' do
              expect(cat.plain_identifiers(id_line)).to include(id_line)
              expect(cat.plain_identifiers(id_line).count).to eq 1
            end

            it 'return multiple items for multi-item input' do
              expect(cat.plain_identifiers(multi_id_line)).to eq multi_id_line.split
            end
          end

          describe '::plain_attribute_definition' do
            let(:cat_im_req) { '{required immutable}' }
            let(:cat_im) { '{immutable}' }
            let(:cat_req) { '{required}' }
            let(:cat_no) { '' }

            it 'returns attribute definition instance' do
              expect(cat.plain_attribute_definition(cat_no)).to be_kind_of(Occi::Core::AttributeDefinition)
            end

            it 'detects required and immutable' do
              expect(cat.plain_attribute_definition(cat_im_req).required?).to be true
              expect(cat.plain_attribute_definition(cat_im_req).mutable?).to be false
            end

            it 'detects immutable' do
              expect(cat.plain_attribute_definition(cat_im_req).mutable?).to be false
            end

            it 'detects required' do
              expect(cat.plain_attribute_definition(cat_im_req).required?).to be true
            end
          end

          describe '::plain_attribute' do
            let(:attr_line_nodef) { 'occi.core.id' }
            let(:attr_line) { 'occi.core.id{required immutable}' }
            let(:bad_attr) { 'occi core id {begh ahsr}' }

            it 'parses attribute from line' do
              expect(cat.plain_attribute(attr_line_nodef)).to be_kind_of Hash
              expect(cat.plain_attribute(attr_line_nodef)).to include(attr_line_nodef)
            end

            it 'parses attribute with defs' do
              expect(cat.plain_attribute(attr_line)).to include(attr_line_nodef)
              expect(cat.plain_attribute(attr_line)[attr_line_nodef].required?).to be true
            end

            it 'fails on malformed attributes' do
              expect { cat.plain_attribute(bad_attr) }.to raise_error(Occi::Core::Errors::ParsingError)
            end
          end

          describe '::plain_attributes' do
            let(:attr1_nodef) { 'occi.core.id' }
            let(:attr2_nodef) { 'occi.storage.size' }
            let(:attrs_line) { 'occi.core.id{required immutable} occi.storage.size' }
            let(:bad_attrs) { 'occi core id {begh ahsr}' }

            it 'fails on malformed attributes' do
              expect { cat.plain_attributes(bad_attrs) }.to raise_error(Occi::Core::Errors::ParsingError)
            end

            it 'parses attributes' do
              expect(cat.plain_attributes(attrs_line)).to include(attr1_nodef, attr2_nodef)
            end
          end

          describe '::plain_category' do
            let(:category) do
              'Category: entity;scheme="http://schemas.ogf.org/occi/core#";class="kind";title="entity";' \
              'location="/entity/";attributes="occi.core.id{immutable required} occi.core.title"'
            end
            let(:bad_category) do
              'cate-gory: entity,scheme="http://schemas.ogf.org/occi/core#",class="kind",title="entity",' \
              'location="/entity/",attributes="occi.core.id{immutable required} occi.core.title"'
            end

            it 'fails on bad category line' do
              expect { cat.plain_category(bad_category) }.to raise_error(Occi::Core::Errors::ParsingError)
            end

            it 'parses valid category line' do
              cati = nil
              expect { cati = cat.plain_category(category) }.not_to raise_error
              expect(cati[:term]).to eq 'entity'
              expect(cati[:scheme]).to eq 'http://schemas.ogf.org/occi/core#'
              expect(cati[:attributes]).to include('occi.core.id', 'occi.core.title')
            end
          end

          describe '::plain' do
            let(:category) do
              'Category: entity;scheme="http://schemas.ogf.org/occi/core#";class="kind";title="entity";' \
              'location="/entity/";attributes="occi.core.id{immutable required} occi.core.title"'
            end
            let(:model) { File.read('examples/rendering/model.txt').lines }
            let(:empty_model) { Occi::Core::Model.new }

            it 'parses valid category' do
              expect { cat.plain([category], empty_model) }.not_to raise_error
              expect(empty_model.categories.first).to be_kind_of(Occi::Core::Kind)
              expect(empty_model.categories.first.identifier).to eq 'http://schemas.ogf.org/occi/core#entity'
              expect(empty_model.categories.first.attributes).to include('occi.core.id', 'occi.core.title')
            end

            it 'parses model example' do
              expect { cat.plain(model, empty_model) }.not_to raise_error
            end
          end
        end
      end
    end
  end
end
