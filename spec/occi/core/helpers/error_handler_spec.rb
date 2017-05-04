module Occi
  module Core
    module Helpers
      describe ErrorHandler do
        subject(:eh) { ErrorHandler }

        let(:klass) { Class.new }
        let(:instance) { klass.new }

        it 'introduces instance method `handle`' do
          expect { klass.include(eh) }.not_to raise_error
          expect(instance).to respond_to(:handle)
        end

        it 'introduces class method `handle`' do
          expect { klass.include(eh) }.not_to raise_error
          expect(klass).to respond_to(:handle)
        end

        describe '#handle' do
          it 'requires a block' do
            expect { klass.include(eh) }.not_to raise_error
            expect { klass.handle(NoMethodError) }.to raise_error(RuntimeError)
          end

          it 'raises the given class' do
            expect { klass.include(eh) }.not_to raise_error
            expect { klass.handle(NoMethodError) { raise 'Test' } }.to raise_error(NoMethodError)
          end
        end
      end
    end
  end
end
