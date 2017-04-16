module Occi
  module Core
    module Parsers
      describe TextParser do
        subject(:tp) { text_parser }

        describe '::model' do
          let(:text_parser) { TextParser }
          let(:model) { File.read('examples/rendering/model.txt') }

          it 'parses model example' do
            expect { tp.model(model, {}, 'text/plain', Occi::Core::Model.new) }.not_to raise_error
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
          it 'does something'
        end

        describe '#categories' do
          it 'does something'
        end
      end
    end
  end
end
