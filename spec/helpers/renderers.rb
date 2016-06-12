module RocciCoreSpec
  module Renderers
    module NotEvenAClassRenderer; end

    class DummyNonRenderer; end

    class DummyFalseRenderer
      class << self
        def renderer?
          false
        end
      end
    end

    class DummyMethodsMissingRenderer
      class << self
        def renderer?
          true
        end
      end
    end

    class DummyNoFormatsRenderer
      class << self
        def renderer?
          true
        end

        def render(object, options)
          # DO NOTHING
        end

        def formats
          nil
        end
      end
    end

    class DummyNoFormatsRenderer
      class << self
        def renderer?
          true
        end

        def render(object, options)
          # DO NOTHING
        end

        def formats
          []
        end
      end
    end

    class DummyWorkingRenderer
      class << self
        def renderer?
          true
        end

        def render(object, options)
          # DO NOTHING
        end

        def formats
          %w(dummy dummier_dummy the_dummiest_dummy).freeze
        end
      end
    end
  end
end
