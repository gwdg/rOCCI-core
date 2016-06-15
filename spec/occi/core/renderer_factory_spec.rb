module Occi
  module Core
    describe RendererFactory do
      describe '#formats' do
        it 'returns enumerable object'
        it 'contains String-like items'
        it 'contains method-compliant names'
      end

      describe '#renderers' do
        it 'returns map from format to renderer'
        it 'returns map with String-like keys and Class-like values'
      end

      describe '#renderer_for' do
        it 'returns renderer for the given format'
        it 'raises error for unknown format'
        it 'raises error when `format` is not specified'
      end

      describe '#renderer_classes' do
        it 'returns Array-like structure'
        it 'returns list of classes'
        it 'returns list of valid renderer classes'
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

      describe '::required_methods' do
        it 'returns default list of required symbols'
      end

      describe '::namespace' do
        it 'returns default namespace module'
      end
    end
  end
end
