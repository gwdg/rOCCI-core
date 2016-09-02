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
              allow(s).to receive(:render).with(kind_of(Object), instance_of(Hash))
            end
          end

          context 'with known type' do
            let(:obj) { Occi::Core::Category.new(term: 'cat', schema: 'http://test.schema.org/test#') }

            it 'delegates to serializer' do
              expect { trc.render(obj, {}) }.not_to raise_error
            end
          end

          context 'with unknown type' do
            let(:obj) { Object.new }

            it 'raises error' do
              expect { trc.render(obj, {}) }.to raise_error(Occi::Core::Errors::RenderingError)
            end
          end
        end

        describe '::known_types' do
          it 'returns enumerable' do
            expect(trc.known_types).to be_kind_of(Enumerable)
          end

          it 'is not empty' do
            expect(trc.known_types).not_to be_empty
          end

          it 'returns strings' do
            trc.known_types.each { |type| expect(type).to be_kind_of(String) }
          end
        end

        describe '::known_serializers' do
          it 'returns enumerable' do
            expect(trc.known_serializers).to be_kind_of(Enumerable)
          end

          it 'is not empty' do
            expect(trc.known_serializers).not_to be_empty
          end

          it 'returns classes' do
            trc.known_serializers.each { |serializer| expect(serializer).to be_kind_of(Class) }
          end
        end

        describe '::known' do
          it 'returns enumerable' do
            expect(trc.known).to be_kind_of(Hash)
          end

          it 'is not empty' do
            expect(trc.known).not_to be_empty
          end
        end
      end
    end
  end
end
