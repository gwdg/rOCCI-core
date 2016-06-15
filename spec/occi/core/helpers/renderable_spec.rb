module Occi
  module Core
    module Helpers
      describe Renderable do
        subject { Renderable }

        let(:renderable_object) do
          object = instance_double('Object')
          object.extend(subject)
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
            expect { renderable_object.render('not_a_format') }.to raise_error(Occi::Core::Errors::RenderingError)
          end

          it 'delegates to renderer based on `format`'
          it 'passes `options` to renderer'
          it 'passes `format` in `options`'
        end

        describe '::included' do
          before(:each) do
            Singleton.__init__(subject.renderer_factory_class)
            subject.renderer_factory.namespace = RocciCoreSpec::Renderers
          end

          after(:each) { Singleton.__init__(subject.renderer_factory_class) }

          it 'adds to_dummy method' do
            subject.included(dummy_receiver_class)
            expect(dummy_receiver_class.instance_methods).to include(:to_dummy)
          end

          it 'adds to_dummier_dummy method' do
            subject.included(dummy_receiver_class)
            expect(dummy_receiver_class.instance_methods).to include(:to_dummier_dummy)
          end

          it 'adds to_the_dummiest_dummy method' do
            subject.included(dummy_receiver_class)
            expect(dummy_receiver_class.instance_methods).to include(:to_the_dummiest_dummy)
          end

          it 'overrides existing to_<format> method'
          it 'redirects to #render from to_<format>'
        end

        describe '::extended' do
          it 'raises exception when passed Class'
          it 'executes ::included when passed instance'
        end

        describe '::renderer_factory_class' do
          it 'returns existing class'
          it 'returns singleton-like class'
        end

        describe '::renderer_factory' do
          it 'returns an instance of renderer factory class'
        end
      end
    end
  end
end
