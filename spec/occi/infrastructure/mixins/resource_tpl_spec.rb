module Occi
  module Infrastructure
    module Mixins
      describe ResourceTpl do
        subject { resource_tpl }
        let(:resource_tpl) { Occi::Infrastructure::Mixins::ResourceTpl.new }

        it 'has logger' do
          expect(resource_tpl).to respond_to(:logger)
          expect(resource_tpl.class).to respond_to(:logger)
        end

        it 'is renderable' do
          expect(resource_tpl).to be_kind_of(Occi::Core::Helpers::Renderable)
          expect(resource_tpl).to respond_to(:render)
        end

        it 'inherits from mixin' do
          expect(resource_tpl).to be_kind_of(Occi::Core::Mixin)
        end
      end
    end
  end
end
