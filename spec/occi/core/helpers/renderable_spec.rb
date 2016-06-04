module Occi
  module Core
    module Helpers
      describe Renderable do
        subject { renderable_object }

        let(:renderable_object) do
          object = Object.new
          object.extend(Renderable)
        end

        describe '#render' do
          it 'raises error without `format` specified'
          it 'raises error for unknown `format`'
          it 'raises error for unknown `self.class`'

          it 'delegates to renderer based on `self.class` and `format`'
          it 'passes `options` to renderer'
        end

        describe '::included'
        describe '::extended'
        describe '::available_formats'
        describe '::available_renderers'
        describe '::renderer?'
        describe '::renderer_candidates'
        describe '::required_renderer_methods'
        describe '::renderer_namespace'
      end
    end
  end
end
