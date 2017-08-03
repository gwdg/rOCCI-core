module Occi
  module Core
    module Helpers
      describe MixinSelector do
        let(:selectable_object) do
          object = instance_double('RocciCoreSpec::TestObject')
          object.extend(MixinSelector)
          object
        end

        let(:mxn1) { instance_double('Occi::Core::Mixin') }
        let(:mxn2) { instance_double('Occi::Core::Mixin') }
        let(:mixins_full) { Set.new([mxn1, mxn2]) }

        describe '#select_mixins' do
          before do
            allow(selectable_object).to receive(:mixins).and_return(mixins_full)
            allow(mxn1).to receive(:depends?).with(mxn1).and_return(false)
          end

          context 'without deps' do
            before do
              allow(mxn2).to receive(:depends?).with(mxn1).and_return(false)
            end

            it 'returns empty enumerable' do
              expect(selectable_object.select_mixins(mxn1)).to be_kind_of(Enumerable)
              expect(selectable_object.select_mixins(mxn1)).to be_empty
            end
          end

          context 'with deps' do
            before do
              allow(mxn2).to receive(:depends?).with(mxn1).and_return(true)
            end

            it 'returns dependent mixins' do
              expect(selectable_object.select_mixins(mxn1)).to be_kind_of(Enumerable)
              expect(selectable_object.select_mixins(mxn1)).to include(mxn2)
            end
          end
        end

        describe '#select_mixin' do
          before do
            allow(selectable_object).to receive(:mixins).and_return(mixins_full)
            allow(mxn1).to receive(:depends?).with(mxn1).and_return(false)
          end

          context 'without deps' do
            before do
              allow(mxn2).to receive(:depends?).with(mxn1).and_return(false)
            end

            it 'returns nil' do
              expect(selectable_object.select_mixin(mxn1)).to be_nil
            end
          end

          context 'with deps' do
            before do
              allow(mxn2).to receive(:depends?).with(mxn1).and_return(true)
            end

            it 'returns dependent mixin' do
              expect(selectable_object.select_mixin(mxn1)).to be mxn2
            end
          end
        end

        describe '#select_mixin!' do
          before do
            allow(selectable_object).to receive(:mixins).and_return(mixins_full)
            allow(mxn1).to receive(:depends?).with(mxn1).and_return(false)
          end

          context 'without deps' do
            before do
              allow(mxn2).to receive(:depends?).with(mxn1).and_return(false)
            end

            it 'raises error' do
              expect { selectable_object.select_mixin!(mxn1) }.to raise_error(Occi::Core::Errors::InstanceLookupError)
            end
          end

          context 'with deps' do
            before do
              allow(mxn2).to receive(:depends?).with(mxn1).and_return(true)
            end

            it 'returns dependent mixin' do
              expect(selectable_object.select_mixin!(mxn1)).to be mxn2
            end
          end
        end
      end
    end
  end
end
