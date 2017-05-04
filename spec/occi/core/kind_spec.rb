module Occi
  module Core
    describe Kind do
      subject(:knd) { kind }

      let(:example_term) { 'kind' }
      let(:example_schema) { 'http://schemas.org/schema#' }
      let(:example_title) { 'Generic kind' }

      let(:root_kind) do
        Kind.new(
          term: 'root',
          schema: 'http://test.org/root#',
          title: 'Root kind'
        )
      end

      let(:kind) do
        Kind.new(
          term: example_term,
          schema: example_schema,
          title: example_title,
          parent: root_kind
        )
      end

      let(:successor_kind) do
        Kind.new(
          term: 'succ',
          schema: 'http://test.org/succ#',
          title: 'Succ kind',
          parent: kind
        )
      end

      KIND_ATTRS = %i[parent location actions].freeze

      KIND_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      describe '::new' do
        let(:attr_def) { instance_double(Occi::Core::AttributeDefinition) }
        let(:new_attr_def) { instance_double(Occi::Core::AttributeDefinition) }
        let(:root_kind) do
          rkind = Kind.new(term: 'root', schema: 'http://test.org/root#', title: 'Root kind')
          rkind.attributes['my.test.attr'] = attr_def
          rkind
        end
        let(:successor_kind) do
          Kind.new(
            term: 'succ', schema: 'http://test.org/succ#', title: 'Succ kind', parent: kind,
            attributes: { 'my.test.attr' => new_attr_def }
          )
        end

        it 'inherits attributes from parent' do
          expect(kind.attributes.keys).to include('my.test.attr')
          expect(kind.attributes['my.test.attr']).to eq attr_def
        end

        it 'overwrites attributes on parent' do
          expect(kind.attributes['my.test.attr']).to eq attr_def
          expect(successor_kind.attributes['my.test.attr']).to eq new_attr_def
        end

        it 'works without parent' do
          expect { Kind.new term: example_term, schema: example_schema }.not_to raise_error
        end
      end

      describe '#related?' do
        it 'returns `false` without `kind`' do
          expect(knd.related?(nil)).to be false
        end

        it 'returns `false` for not related' do
          expect(knd.related?('wat?')).to be false
        end

        it 'returns `false` for successor kind' do
          expect(knd.related?(successor_kind)).to be false
        end

        it 'returns `true` for related' do
          expect(knd.related?(root_kind)).to be true
        end
      end

      describe '#directly_related?' do
        subject(:knd) { successor_kind }

        it 'returns `false` without `kind`' do
          expect(knd.directly_related?(nil)).to be false
        end

        it 'returns `false` for not related' do
          expect(knd.directly_related?('wat?')).to be false
        end

        it 'returns `false` for not directly related' do
          expect(knd.directly_related?(root_kind)).to be false
        end

        it 'returns `true` for directly related' do
          expect(knd.directly_related?(kind)).to be true
        end
      end

      describe '#related' do
        subject(:knd) { root_kind.related }

        it 'returns enumerable list' do
          expect(knd).to be_kind_of(Enumerable)
        end

        it 'returns empty list for root' do
          expect(knd).to be_empty
        end

        it 'returns non-empty list for non-root kind' do
          expect(kind.related).to include(root_kind)
          expect(kind.related.count).to be 1
        end

        it 'returns non-empty list for multi-predecessor kind' do
          expect(successor_kind.related).to include(kind)
          expect(successor_kind.related).to include(root_kind)
          expect(successor_kind.related.count).to be 2
        end
      end

      describe '#directly_related' do
        subject(:knd) { root_kind.directly_related }

        it 'returns enumerable list' do
          expect(knd).to be_kind_of(Enumerable)
        end

        it 'returns empty list for root' do
          expect(knd).to be_empty
        end

        it 'returns single-element list for single-predecessor kind' do
          expect(kind.directly_related.count).to eq 1
          expect(kind.directly_related).to include(root_kind)
        end

        it 'returns single-element list for multi-predecessor kind' do
          expect(successor_kind.directly_related.count).to eq 1
          expect(successor_kind.directly_related).to include(kind)
        end
      end

      describe '#hierarchy_root?' do
        it 'returns `false` for non-root kind' do
          expect(root_kind.hierarchy_root?).to be true
        end

        it 'returns `true` for root kind' do
          expect(successor_kind.hierarchy_root?).to be false
        end
      end

      describe '#location' do
        context 'without term and location' do
          before do
            knd.term = nil
            knd.location = nil
          end

          it 'fails' do
            expect { knd.location }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end

        context 'with term and without location' do
          before { knd.location = nil }

          it 'returns default' do
            expect(knd.location).to be_kind_of URI
          end
        end
      end
    end
  end
end
