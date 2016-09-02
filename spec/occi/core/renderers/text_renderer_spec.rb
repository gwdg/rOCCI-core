module Occi
  module Core
    module Renderers
      describe TextRenderer do
        subject(:trc) { TextRenderer }

        it 'has logger' do
          expect(trc).to respond_to(:logger)
        end

        describe '::renderer?' do
          it 'return true' do
            expect(trc.renderer?).to be true
          end
        end

        describe '::formats' do
          it 'return non-empty enumerable' do
            expect(trc.formats).not_to be_empty
            expect(trc.formats).to be_kind_of(Enumerable)
          end
        end

        describe '::render' do
          before(:example) do
            trc.known_serializers.each do |s|
              allow(s).to receive(:render).with(instance_of(Object), instance_of(Hash))
            end
          end
        end

        describe '::known_types'
        describe '::known_serializers'
        describe '::known'
      end
    end
  end
end
