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
      end
    end
  end
end
