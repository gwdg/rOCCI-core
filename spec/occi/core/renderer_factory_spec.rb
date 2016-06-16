module Occi
  module Core
    describe RendererFactory do
      subject { RendererFactory }

      let(:test_namespace) { RocciCoreSpec::Renderers }
      let(:orig_namespace) { Occi::Core::Renderers }
      let(:dummy_renderer) { RocciCoreSpec::Renderers::DummyWorkingRenderer }

      before(:each) do
        Singleton.__init__(RendererFactory)
        stub_const('Occi::Core::RendererFactory::NAMESPACE', test_namespace)
      end

      after(:each) do
        Singleton.__init__(RendererFactory)
        stub_const('Occi::Core::RendererFactory::NAMESPACE', orig_namespace)
      end

      let(:factory_instance) { RendererFactory.instance }
      let(:dummy_formats) { %w(dummy dummier_dummy the_dummiest_dummy) }
      let(:required_methods) { [:renderer?, :formats, :render] }

      describe '#formats' do
        subject { factory_instance.formats }

        it 'returns enumerable object' do
          expect(subject).to be_kind_of(Enumerable)
        end

        it 'contains String-like items' do
          subject.each { |it| expect(it).to be_kind_of(String) }
        end

        it 'contains method-compliant names' do
          subject.each { |it| expect(it).not_to include(' ') }
        end

        it 'publishes all known formats' do
          expect(subject).to eq dummy_formats
        end
      end

      describe '#renderers' do
        subject { factory_instance.renderers }

        it 'returns hash' do
          expect(subject).to be_kind_of(Hash)
        end

        it 'returns hash with String-like keys and Class-like values' do
          subject.keys.each { |k| expect(k).to be_kind_of(String) }
          subject.values.each { |v| expect(v).to be_kind_of(Class) }
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
        subject { factory_instance.renderer_classes }

        it 'returns enumerable object' do
          expect(subject).to be_kind_of(Enumerable)
        end

        it 'returns list of classes' do
          subject.each { |it| expect(it).to be_kind_of(Class) }
        end

        it 'returns list of valid renderer classes' do
          subject.each { |it| expect(it).to respond_to(:render) }
        end
      end

      describe '::renderer?' do
        let(:object) { Object.new }
        let(:klass) { Class.new }

        let(:klass_non_renderer) do
          klass.define_singleton_method('renderer?', proc { false })
        end

        let(:klass_renderer) do
          klass.define_singleton_method('renderer?', proc { true })
          klass.define_singleton_method('formats', proc { ['dummy'] })
          klass.define_singleton_method('render', proc { 'test' })
        end

        it 'returns false for non-Class arguments' do
          expect(subject.renderer?(object, required_methods)).to be false
        end

        it 'returns false for classes not responding to required methods' do
          expect(subject.renderer?(klass, required_methods)).to be false
        end

        it 'returns false for classes claiming not to be renderer' do
          expect(subject.renderer?(klass_non_renderer, required_methods)).to be false
        end

        it 'returns true for classes claiming to be renderer' do
          expect(subject.renderer?(klass_renderer, required_methods)).to be true
        end
      end

      describe '::renderer_candidates' do
        let(:empty_module) { Module.new }
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

        it 'lists candidates from given namespace' do
          expect(subject.renderer_candidates(test_namespace)).to eq expected_consts
        end

        it 'returns empty list for empty namespace' do
          expect(subject.renderer_candidates(empty_module)).to eq []
        end
      end

      describe '::required_methods' do
        it 'returns default list of required symbols' do
          expect(subject.required_methods).to eq required_methods
        end
      end

      describe '::namespace' do
        it 'returns default namespace module' do
          expect(subject.namespace).to eq test_namespace
        end
      end
    end
  end
end
