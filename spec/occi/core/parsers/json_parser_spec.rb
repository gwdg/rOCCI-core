module Occi
  module Core
    module Parsers
      describe JsonParser do
        subject(:jp) { json_parser }

        describe '::model' do
          let(:json_parser) { JsonParser }
          let(:model) { File.read('examples/rendering/model.json') }
          let(:model_alt) { File.read('examples/rendering/model.alt.json') }

          it 'parses model example' do
            m = Occi::Core::Model.new
            expect { jp.model(model, {}, 'application/occi+json', m) }.not_to raise_error
            expect { m.valid! }.not_to raise_error
          end

          it 'parses alternate model example' do
            m = Occi::Core::Model.new
            expect { jp.model(model_alt, {}, 'application/occi+json', m) }.not_to raise_error
            expect { m.valid! }.not_to raise_error
          end
        end

        describe '::locations' do
          let(:json_parser) { JsonParser }

          context 'with application/occi+json' do
            let(:locs) do
              '["http://localhost/meh/1","http://localhost/meh/2"]'
            end

            it 'parses locations' do
              expect { jp.locations(locs, {}, 'application/occi+json') }.not_to raise_error
            end
          end
        end

        describe '#entities' do
          let(:json_parser) { JsonParser.new(model: model, media_type: 'application/json') }
          let(:instance) { File.read('examples/rendering/instance.json') }
          let(:model) do
            m = Occi::Infrastructure::Model.new
            m.load_core!
            m.load_infrastructure!
            m
          end

          it 'parses entities' do
            inst = nil
            expect { inst = jp.entities(instance, {}, Occi::Infrastructure::Compute) }.not_to raise_error
            expect { inst.first.valid! }.not_to raise_error
          end
        end

        describe '#categories' do
          let(:json_parser) { JsonParser.new(model: model, media_type: 'application/json') }
          let(:categories) { File.read('examples/rendering/categories.json') }
          let(:model) do
            m = Occi::Infrastructure::Model.new
            m.load_core!
            m.load_infrastructure!
            m
          end

          it 'parses categories' do
            expect { jp.categories(categories, {}) }.not_to raise_error
          end
        end

        describe '#action_instances' do
          let(:json_parser) { JsonParser.new(model: model, media_type: 'application/json') }
          let(:action_instance) { File.read('examples/rendering/action_instance.json') }
          let(:model) do
            m = Occi::Infrastructure::Model.new
            m.load_core!
            m.load_infrastructure!
            m
          end

          it 'parses action instances' do
            expect { jp.action_instances(action_instance, {}) }.not_to raise_error
          end
        end
      end
    end
  end
end
