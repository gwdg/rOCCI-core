module Occi
  module Core
    describe Kind do
      subject { kind }

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

      KIND_ATTRS = [:parent, :location, :actions].freeze

      KIND_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      describe 'related?' do
        it 'returns `false` without `kind`' do
          expect(subject.related?(nil)).to be false
        end

        it 'returns `false` for not related' do
          expect(subject.related?('wat?')).to be false
        end

        it 'returns `false` for successor kind' do
          expect(subject.related?(successor_kind)).to be false
        end

        it 'returns `true` for related' do
          expect(subject.related?(root_kind)).to be true
        end
      end

      describe 'directly_related?' do
        subject { successor_kind }

        it 'returns `false` without `kind`' do
          expect(subject.directly_related?(nil)).to be false
        end

        it 'returns `false` for not related' do
          expect(subject.directly_related?('wat?')).to be false
        end

        it 'returns `false` for not directly related' do
          expect(subject.directly_related?(root_kind)).to be false
        end

        it 'returns `true` for directly related' do
          expect(subject.directly_related?(kind)).to be true
        end
      end

      describe 'related' do
        subject { root_kind.related }

        it 'returns enumerable list' do
          expect(subject).to be_kind_of(Enumerable)
        end

        it 'returns empty list for root' do
          expect(subject).to be_empty
        end

        it 'returns non-empty list for non-root kind' do
          expect(kind.related.count).to eq 1
        end

        it 'returns non-empty list for multi-predecessor kind' do
          expect(successor_kind.related.count).to eq 2
        end
      end

      describe 'directly_related' do
        subject { root_kind.directly_related }

        it 'returns enumerable list' do
          expect(subject).to be_kind_of(Enumerable)
        end

        it 'returns empty list for root' do
          expect(subject).to be_empty
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

      describe 'hierarchy_root?' do
        it 'returns `false` for non-root kind' do
          expect(root_kind.hierarchy_root?).to be true
        end

        it 'returns `true` for root kind' do
          expect(successor_kind.hierarchy_root?).to be false
        end
      end
    end
  end
end
