module Occi
  module Infrastructure
    describe Model do
      subject { model }

      let(:model) { Occi::Infrastructure::Model.new }

      describe '#load_infrastructure!' do
        context 'without Core specs' do
          it 'fails to load Infra specs' do
            expect { model.load_infrastructure! }.to raise_error(Occi::Core::Errors::ModelLookupError)
          end
        end

        context 'with Core specs' do
          before { model.load_core! }

          it 'loads Infra specs' do
            expect { model.load_infrastructure! }.not_to raise_error
          end
        end
      end

      describe '#instance_builder' do
        it 'returns IB instance' do
          expect(model.instance_builder).to be_kind_of Occi::Infrastructure::InstanceBuilder
        end
      end

      describe '#find_os_tpls' do
        before do
          model.load_core!
          model.load_infrastructure!
        end

        context 'without os_tpl mixins' do
          it 'returns empty collection' do
            expect(model.find_os_tpls).to be_empty
          end
        end

        context 'with os_tpl mixins' do
          let(:os_tpl_base) { Occi::Infrastructure::Mixins::OsTpl.new }
          let(:os_tpl) do
            Occi::Core::Mixin.new(
              term: 'test',
              schema: 'http://test/1#',
              depends: Set.new([os_tpl_base])
            )
          end

          before { model << os_tpl }

          it 'returns only os_tpl mixins' do
            expect(model.find_os_tpls).to include(os_tpl)
          end
        end
      end

      describe '#find_resource_tpls' do
        before do
          model.load_core!
          model.load_infrastructure!
        end

        context 'without resource_tpl mixins' do
          it 'returns empty collection' do
            expect(model.find_resource_tpls).to be_empty
          end
        end

        context 'with resource_tpl mixins' do
          let(:resource_tpl_base) { Occi::Infrastructure::Mixins::ResourceTpl.new }
          let(:resource_tpl) do
            Occi::Core::Mixin.new(
              term: 'test',
              schema: 'http://test/1#',
              depends: Set.new([resource_tpl_base])
            )
          end

          before { model << resource_tpl }

          it 'returns only resource_tpl mixins' do
            expect(model.find_resource_tpls).to include(resource_tpl)
          end
        end
      end
    end
  end
end
