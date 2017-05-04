module Occi
  module Core
    module Parsers
      describe TextParser do
        subject(:tp) { text_parser }

        describe '::model' do
          let(:text_parser) { TextParser }
          let(:model) { File.read('examples/rendering/model.txt') }

          it 'parses model example' do
            m = Occi::Core::Model.new
            expect { tp.model(model, {}, 'text/plain', m) }.not_to raise_error
            expect { m.valid! }.not_to raise_error
          end
        end

        describe '::locations' do
          let(:text_parser) { TextParser }

          context 'with uri-list' do
            let(:locs) do
              "http://localhost/meh/1\nhttp://localhost/meh/2"
            end

            it 'parses locations' do
              expect { tp.locations(locs, {}, 'text/uri-list') }.not_to raise_error
            end
          end

          context 'with text/plain' do
            let(:locs) do
              "X-OCCI-Location: http://localhost/meh/1\nX-OCCI-Location: http://localhost/meh/2"
            end

            it 'parses locations' do
              expect { tp.locations(locs, {}, 'text/plain') }.not_to raise_error
            end
          end
        end

        describe '#entities' do
          let(:text_parser) { TextParser.new(model: model, media_type: 'text/plain') }
          let(:instance) { File.read('examples/rendering/instance.txt') }
          let(:model) do
            m = Occi::Infrastructure::Model.new
            m.load_core!
            m.load_infrastructure!
            m
          end

          it 'parses entities' do
            inst = nil
            expect { inst = tp.entities(instance, {}, Occi::Infrastructure::Compute) }.not_to raise_error
            expect { inst.first.valid! }.not_to raise_error
          end
        end

        describe '#categories' do
          let(:text_parser) { TextParser.new(model: model, media_type: 'text/plain') }
          let(:categories) { File.read('examples/rendering/categories.txt') }
          let(:model) do
            m = Occi::Infrastructure::Model.new
            m.load_core!
            m.load_infrastructure!
            m
          end

          it 'parses categories' do
            expect { tp.categories(categories, {}) }.not_to raise_error
          end
        end

        describe '#action_instances' do
          let(:text_parser) { TextParser.new(model: model, media_type: 'text/plain') }
          let(:action_instance) { File.read('examples/rendering/action_instance.txt') }
          let(:model) do
            m = Occi::Infrastructure::Model.new
            m.load_core!
            m.load_infrastructure!
            m
          end

          it 'parses action instances' do
            expect { tp.action_instances(action_instance, {}) }.not_to raise_error
          end
        end
      end
    end
  end
end
