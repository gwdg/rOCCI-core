module Occi
  module Core
    module Rendering
      describe Renderable do
        subject { renderable_object }

        let(:renderable_object) do
          object = Object.new
          object.extend(Renderable)
        end

        it 'exposes #render'

        describe '#render' do
          it 'raises error without `format` specified'
          it 'raises error for unknown `format`'
          it 'raises error for unknown `self.class`'

          it 'delegates to renderer based on `self.class` and `format`'
          it 'passes `options` to renderer'
        end

        describe '#respond_to?' do
          context 'for existing methods' do
            it 'returns `true`'
          end

          context 'for missing methods' do
            context 'matching `to_<format>`' do
              it 'returns `true` with corresponding renderer'
              it 'returns `false` without corresponding renderer'
            end

            context 'not matching `to_<format>`' do
              it 'returns `false`'
            end
          end
        end

        describe '#method_missing' do
          context 'for methods matching `to_<format>`' do
            context 'with corresponding renderer' do
              it 'calls `render` with `format`'
            end

            context 'without corresponding renderer' do
              it 'raises `NoMethodError` error'
            end
          end

          it 'raises `NoMethodError` error'
        end

        describe '#methods'
        describe '#public_methods'
      end
    end
  end
end
