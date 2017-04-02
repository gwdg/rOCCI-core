module Occi
  module Infrastructure
    module Mixins
      describe OsTpl do
        subject { os_tpl }
        let(:os_tpl) { Occi::Infrastructure::Mixins::OsTpl.new }

        it 'has logger' do
          expect(os_tpl).to respond_to(:logger)
          expect(os_tpl.class).to respond_to(:logger)
        end

        it 'is renderable' do
          expect(os_tpl).to be_kind_of(Occi::Core::Helpers::Renderable)
          expect(os_tpl).to respond_to(:render)
        end

        it 'inherits from mixin' do
          expect(os_tpl).to be_kind_of(Occi::Core::Mixin)
        end
      end
    end
  end
end
