module Occi
  module Core
    describe RendererFactory do
      subject(:rfm) { RendererFactory }

      let(:test_namespace) { RocciCoreSpec::Renderers }
      let(:orig_namespace) { Occi::Core::Renderers }
      let(:dummy_renderer) { RocciCoreSpec::Renderers::DummyWorkingRenderer }
      let(:factory_instance) { RendererFactory.instance }
      let(:dummy_formats) { %w[dummy dummier_dummy the_dummiest_dummy] }
      let(:required_methods) { %i[renderer? formats render] }

      before do
        Singleton.__init__(RendererFactory)
        stub_const('Occi::Core::RendererFactory::NAMESPACE', test_namespace)
      end

      after do
        Singleton.__init__(RendererFactory)
        stub_const('Occi::Core::RendererFactory::NAMESPACE', orig_namespace)
      end

      describe '#formats' do
        subject(:fif) { factory_instance.formats }

        it 'returns enumerable object' do
          expect(fif).to be_kind_of(Enumerable)
        end

        it 'contains String-like items' do
          expect(fif).to all(be_kind_of(String))
        end

        it 'contains method-compliant names' do
          fif.each { |v| expect(v).not_to include(' ') }
        end

        it 'publishes all known formats' do
          expect(fif).to eq dummy_formats
        end
      end

      describe '#renderers' do
        subject(:fir) { factory_instance.renderers }

        it 'returns hash' do
          expect(fir).to be_kind_of(Hash)
        end

        it 'returns hash with String-like keys and Class-like values' do
          expect(fir.keys).to all(be_kind_of(String))
          expect(fir.values).to all(be_kind_of(Class))
        end
      end

      describe '#renderer_for' do
        it 'returns renderer for the given format' do
          expect(factory_instance.renderer_for('dummy')).to eq dummy_renderer
        end

        it 'raises error for unknown format' do
          expect { factory_instance.renderer_for('does_not_exist') }.to raise_error(Occi::Core::Errors::RenderingError)
        end

        it 'raises error when `format` is not specified' do
          expect { factory_instance.renderer_for(nil) }.to raise_error(Occi::Core::Errors::RenderingError)
        end

        it 'raises error when empty `format` is specified' do
          expect { factory_instance.renderer_for('') }.to raise_error(Occi::Core::Errors::RenderingError)
        end
      end

      describe '#renderer_classes' do
        subject(:firc) { factory_instance.renderer_classes }

        it 'returns enumerable object' do
          expect(firc).to be_kind_of(Enumerable)
        end

        it 'returns list of classes' do
          expect(firc).to all(be_kind_of(Class))
        end

        it 'returns list of valid renderer classes' do
          expect(firc).to all(respond_to(:render))
        end
      end

      describe '#renderer?' do
        subject(:fi) { factory_instance }

        let(:object) { Object.new }
        let(:klass) { Class.new }

        let(:klass_non_renderer) do
          klass.define_singleton_method('renderer?', proc { false })
          klass
        end

        let(:klass_renderer) do
          klass.define_singleton_method('renderer?', proc { true })
          klass.define_singleton_method('formats', proc { ['dummy'] })
          klass.define_singleton_method('render', proc { 'test' })
          klass
        end

        it 'returns false for non-Class arguments' do
          expect(fi.renderer?(object)).to be false
        end

        it 'returns false for classes not responding to required methods' do
          expect(fi.renderer?(klass)).to be false
        end

        it 'returns false for classes claiming not to be renderer' do
          expect(fi.renderer?(klass_non_renderer)).to be false
        end

        it 'returns true for classes claiming to be renderer' do
          expect(fi.renderer?(klass_renderer)).to be true
        end
      end

      describe '::constants_from' do
        let(:empty_module) { Module.new }
        let(:empty_non_module) { Object.new }

        let(:expected_consts) do
          ['test_constant',
           RocciCoreSpec::Renderers::NotEvenAClassRenderer,
           RocciCoreSpec::Renderers::DummyNonRenderer,
           RocciCoreSpec::Renderers::DummyFalseRenderer,
           RocciCoreSpec::Renderers::DummyTrueRenderer,
           RocciCoreSpec::Renderers::DummyTrueRenderRenderer,
           RocciCoreSpec::Renderers::DummyNoFormatsRenderer,
           RocciCoreSpec::Renderers::DummyEmptyFormatsRenderer,
           RocciCoreSpec::Renderers::DummyWorkingRenderer]
        end

        it 'lists constants from given namespace' do
          expect(rfm.constants_from(test_namespace)).to eq expected_consts
        end

        it 'returns empty list for empty namespace' do
          expect(rfm.constants_from(empty_module)).to eq []
        end

        it 'raises error when not passed a Module' do
          expect { rfm.constants_from(empty_non_module) }.to raise_error(Occi::Core::Errors::RendererError)
        end
      end

      describe '::classes_from' do
        let(:empty_module) { Module.new }
        let(:empty_non_module) { Object.new }

        let(:expected_classes) do
          [RocciCoreSpec::Renderers::DummyNonRenderer,
           RocciCoreSpec::Renderers::DummyFalseRenderer,
           RocciCoreSpec::Renderers::DummyTrueRenderer,
           RocciCoreSpec::Renderers::DummyTrueRenderRenderer,
           RocciCoreSpec::Renderers::DummyNoFormatsRenderer,
           RocciCoreSpec::Renderers::DummyEmptyFormatsRenderer,
           RocciCoreSpec::Renderers::DummyWorkingRenderer]
        end

        it 'returns list of classes' do
          expect(rfm.classes_from(test_namespace)).to eq expected_classes
        end

        it 'raises error when not passed a Module' do
          expect { rfm.classes_from(empty_non_module) }.to raise_error(Occi::Core::Errors::RendererError)
        end

        it 'returns empty list for empty namespace' do
          expect(rfm.classes_from(empty_module)).to eq []
        end
      end

      describe '::required_methods' do
        it 'returns default list of required symbols' do
          expect(rfm.required_methods).to eq required_methods
        end
      end

      describe '::namespace' do
        it 'returns default namespace module' do
          expect(rfm.namespace).to eq test_namespace
        end
      end
    end
  end
end
