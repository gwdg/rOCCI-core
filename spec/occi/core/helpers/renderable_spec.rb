module Occi
  module Core
    module Helpers
      describe Renderable do
        subject(:renderable_module) { Renderable }

        before(:each) do
          Singleton.__init__(Renderable::RENDERER_FACTORY_CLASS)
          stub_const('Occi::Core::RendererFactory::NAMESPACE', RocciCoreSpec::Renderers)
        end

        after(:each) do
          Singleton.__init__(Renderable::RENDERER_FACTORY_CLASS)
          stub_const('Occi::Core::RendererFactory::NAMESPACE', Occi::Core::RendererFactory)
        end

        let(:dummy_receiver_class) { Class.new }

        let(:dummy_receiver_instance) { dummy_receiver_class.new }

        let(:renderable_object) do
          object = instance_double('RocciCoreSpec::TestObject')
          object.extend(renderable_module)
        end

        describe '#render' do
          it 'raises error without `format` specified' do
            expect { renderable_object.render(nil) }.to raise_error(Occi::Core::Errors::RenderingError)
          end

          it 'raises error with empty `format` specified' do
            expect { renderable_object.render('') }.to raise_error(Occi::Core::Errors::RenderingError)
          end

          it 'raises error for unknown `format`' do
            expect { renderable_object.render('not_a_format') }.to raise_error(Occi::Core::Errors::RenderingError)
          end

          it 'delegates to renderer based on `format`' do
            expect(renderable_object.render('dummy')).to eq 'RocciCoreSpec::Renderers::DummyWorkingRenderer'
          end
        end

        describe '#renderer_for' do
          it 'returns renderer for existing format' do
            expect(renderable_object.renderer_for('dummy')).to eq RocciCoreSpec::Renderers::DummyWorkingRenderer
          end

          it 'raises error for non-existent format' do
            expect { renderable_object.renderer_for('not_format') }.to raise_error(Occi::Core::Errors::RenderingError)
          end

          it 'returns class' do
            expect(renderable_object.renderer_for('dummy')).to be_kind_of(Class)
          end
        end

        describe '#renderer_factory' do
          it 'returns renderer factory instance' do
            expect(renderable_object.renderer_factory).to be_instance_of(Renderable::RENDERER_FACTORY_CLASS)
          end
        end

        describe '::included' do
          it 'adds to_dummy method' do
            renderable_module.included(dummy_receiver_class)
            expect(dummy_receiver_class.instance_methods).to include(:to_dummy)
          end

          it 'adds to_dummier_dummy method' do
            renderable_module.included(dummy_receiver_class)
            expect(dummy_receiver_class.instance_methods).to include(:to_dummier_dummy)
          end

          it 'adds to_the_dummiest_dummy method' do
            renderable_module.included(dummy_receiver_class)
            expect(dummy_receiver_class.instance_methods).to include(:to_the_dummiest_dummy)
          end

          it 'overrides existing to_<format> method' do
            expect(renderable_object.to_the_dummiest_dummy).to eq 'RocciCoreSpec::Renderers::DummyWorkingRenderer'
          end
        end

        describe '::extended' do
          it 'raises exception when passed Class' do
            expect { renderable_module.extended(dummy_receiver_class) }.to raise_error(RuntimeError)
          end

          it 'executes ::included when passed instance' do
            expect { renderable_module.extended(dummy_receiver_instance) }.not_to raise_error
          end
        end

        describe '::renderer_factory_class' do
          it 'returns existing class' do
            expect(renderable_module.renderer_factory_class).to be_kind_of(Class)
          end

          it 'returns singleton-like class' do
            expect(renderable_module.renderer_factory_class).to respond_to(:instance)
          end
        end

        describe '::renderer_factory' do
          it 'returns an instance of renderer factory class' do
            expect(renderable_module.renderer_factory).to be_instance_of(Renderable::RENDERER_FACTORY_CLASS)
          end
        end
      end
    end
  end
end
