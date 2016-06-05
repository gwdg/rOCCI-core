module Occi
  module Core
    module Helpers
      describe Renderable do
        subject { Renderable }

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

        describe '::included' do
          context 'for every <format>' do
            it 'adds to_<format> method'
            it 'overrides existing to_<format> method'
            it 'redirects to #render from to_<format>'
          end
        end

        describe '::extended' do
          it 'raises exception when passed Class'
          it 'executes ::included when passed instance'
        end

        describe '::available_formats' do
          it 'returns enumerable object'
          it 'contains String-like items'
          it 'contains method-compliant names'
        end

        describe '::available_renderers' do
          it 'returns a map from format to renderer'
          it 'returns a map with String-like keys and Class-like values'
        end

        describe '::renderer?' do
          it 'returns false for non-Class arguments'
          it 'returns false for classes not responding to required methods'
          it 'returns false for classes claiming not to be renderer'
          it 'returns true for classes claiming to be renderer'
        end

        describe '::renderer_candidates' do
          it 'lists candidates from given namespace'
          it 'returns empty list for empty namespace'
        end

        describe '::required_renderer_methods' do
          it 'returns default list of required symbols'
        end

        describe '::renderer_namespace' do
          it 'returns default namespace module'
        end
      end
    end
  end
end
