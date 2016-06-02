module Occi
  module Core
    module Renderers
      describe Renderable do
        subject { renderable_object }

        let(:renderable_object) do
          object = Object.new
          object.include(Renderable)
        end

        describe '#render' do
          it 'raises error without `format` specified'
          it 'raises error for unknown `format`'
          it 'raises error for unknown `self.class`'

          it 'delegates to renderer based on `self.class` and `format`'
          it 'passes `options` to renderer'
        end

        describe '::included' do
        end
      end
    end
  end
end
