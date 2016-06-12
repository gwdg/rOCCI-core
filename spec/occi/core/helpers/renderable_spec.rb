module Occi
  module Core
    module Helpers
      describe Renderable do
        subject { Renderable }

        # Hack renderer loading for testing
        silence_warnings { Renderable::RENDERER_NAMESPACE = RocciCoreSpec::Renderers }

        let(:renderable_object) do
          object = instance_double('Object')
          object.extend(Renderable)
        end

        let(:dummy_receiver_class) do
          Class.new
        end

        let(:dummy_receiver_instance) do
          dummy_receiver_class.new
        end

        describe '#render' do
          it 'raises error without `format` specified' do
            expect { renderable_object.render(nil) }.to raise_error(Occi::Core::Errors::RenderingError)
            expect { renderable_object.render('') }.to raise_error(Occi::Core::Errors::RenderingError)
          end

          it 'raises error for unknown `format`' do
            expect(renderable_object.render('definitely_not_a_format')).to raise_error(Occi::Core::RenderingError)
          end

          it 'delegates to renderer based on `format`'
          it 'passes `options` to renderer'
          it 'passes `format` in `options`'
        end

        describe '::included' do
          context 'for every <format>' do
            it 'adds to_<format> method' do
              subject.included(dummy_receiver_class)
              expect(dummy_receiver_class).to respond_to(:to_dummy)
              expect(dummy_receiver_class).to respond_to(:to_dummier_dummy)
              expect(dummy_receiver_class).to respond_to(:to_the_dummiest_dummy)
            end

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
