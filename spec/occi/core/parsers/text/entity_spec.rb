module Occi
  module Core
    module Parsers
      module Text
        describe Entity do
          subject(:ent) { Entity }

          it 'has logger' do
            expect(ent).to respond_to(:logger)
          end

          it 'does something'
        end
      end
    end
  end
end
