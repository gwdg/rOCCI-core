module Occi
  module Core
    module Parsers
      module Text
        describe Entity do
          subject(:ent) { entity_parser }

          let(:model) { Occi::Core::Model.new }
          let(:entity_parser) { Entity.new(model: model) }

          it 'has logger' do
            expect(ent).to respond_to(:logger)
            expect(ent.class).to respond_to(:logger)
          end

          it 'does something'
        end
      end
    end
  end
end
