module Occi
  module Core
    describe Link do
      subject(:lnk) { link }

      let(:attribute_title) { 'occi.core.title' }
      let(:attribute_id) { 'occi.core.id' }
      let(:attribute_source) { 'occi.core.source' }
      let(:attribute_target) { 'occi.core.target' }
      let(:attributes) do
        {
          attribute_title   => instance_double('Occi::Core::AttributeDefinition'),
          attribute_id      => instance_double('Occi::Core::AttributeDefinition'),
          attribute_source  => instance_double('Occi::Core::AttributeDefinition'),
          attribute_target  => instance_double('Occi::Core::AttributeDefinition')
        }
      end

      let(:attribute_instance) { instance_double('Occi::Core::Attribute') }

      let(:kind) { instance_double('Occi::Core::Kind') }

      let(:link) { Link.new(kind: kind, title: 'My Link') }

      before do
        allow(kind).to receive(:attributes).and_return(attributes)
        allow(kind).to receive(:location).and_return(URI.parse('/kind/'))
        attributes.keys.each { |attrib| allow(attributes[attrib]).to receive(:default) }
      end

      LNK_ATTRS = [:source, :target].freeze

      LNK_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has attributes value accessor' do
        expect(lnk).to be_kind_of(Helpers::InstanceAttributesAccessor)
        expect(lnk).to respond_to(:[])
        expect(lnk).to respond_to(:[]=)
        expect(lnk).to respond_to(:attribute?)
      end

      it 'has logger' do
        expect(lnk).to respond_to(:logger)
        expect(lnk.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(lnk).to be_kind_of(Helpers::Renderable)
        expect(lnk).to respond_to(:render)
      end

      describe '#source=' do
        it 'redirects to `occi.core.source`' do
          expect(lnk).to receive(:[]=).with('occi.core.source', attribute_instance)
          expect { lnk.source = attribute_instance }.not_to raise_error
        end
      end

      describe '#source' do
        it 'redirects to `occi.core.source`' do
          expect(lnk).to receive(:[]).with('occi.core.source')
          expect { lnk.source }.not_to raise_error
        end
      end

      describe '#target=' do
        it 'redirects to `occi.core.target`' do
          expect(lnk).to receive(:[]=).with('occi.core.target', attribute_instance)
          expect { lnk.target = attribute_instance }.not_to raise_error
        end
      end

      describe '#target' do
        it 'redirects to `occi.core.target`' do
          expect(lnk).to receive(:[]).with('occi.core.target')
          expect { lnk.target }.not_to raise_error
        end
      end

      describe '#rel' do
        context 'without target' do
          it 'returns `nil`' do
            expect(lnk.rel).to be nil
          end
        end

        context 'with target' do
          let(:resource) { instance_double('Occi::Core::Resource') }

          before do
            lnk.target = resource
          end

          it 'returns target `kind`' do
            expect(lnk.target).to receive(:kind).and_return(kind)
            expect(lnk.rel).to be kind
          end
        end
      end

      describe '#valid!' do
        context 'with missing required attributes' do
          before do
            lnk.target = nil
            lnk.source = nil
          end

          it 'raises error' do
            expect { lnk.valid! }.to raise_error(Occi::Core::Errors::InstanceValidationError)
          end
        end

        context 'with all required attributes' do
          before do
            lnk.target = attributes['occi.core.target']
            lnk.source = attributes['occi.core.source']
            attributes.values.each { |v| expect(v).to receive(:valid!) }
          end

          it 'passes without error' do
            expect { lnk.valid! }.not_to raise_error
          end
        end
      end
    end
  end
end
