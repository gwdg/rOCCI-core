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
          it 'does something'
        end

        describe '#categories' do
          it 'does something'
        end
      end
    end
  end
end
