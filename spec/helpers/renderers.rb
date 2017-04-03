module RocciCoreSpec
  class TestObject
    def to_the_dummiest_dummy
      'original method'
    end
  end

  module Renderers
    NOT_EVEN_A_MODULE = 'test_constant'.freeze

    module NotEvenAClassRenderer; end

    class DummyNonRenderer; end

    class DummyFalseRenderer
      class << self
        def renderer?
          false
        end
      end
    end

    class DummyTrueRenderer
      class << self
        def renderer?
          true
        end
      end
    end

    class DummyTrueRenderRenderer < DummyTrueRenderer
      class << self
        def render(object, options)
          # DO NOTHING
        end
      end
    end

    class DummyNoFormatsRenderer < DummyTrueRenderRenderer
      class << self
        def formats
          nil
        end
      end
    end

    class DummyEmptyFormatsRenderer < DummyTrueRenderRenderer
      class << self
        def formats
          []
        end
      end
    end

    class DummyWorkingRenderer < DummyTrueRenderRenderer
      class << self
        def formats
          %w[dummy dummier_dummy the_dummiest_dummy].freeze
        end

        def render(_object, _options)
          name
        end
      end
    end
  end
end
