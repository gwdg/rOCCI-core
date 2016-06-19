module Occi
  module Core
    describe Mixin do
      subject { mixin }

      let(:example_term) { 'mixin' }
      let(:example_schema) { 'http://schemas.org/schema#' }
      let(:example_title) { 'Generic mixin' }
      let(:kind_double) { instance_double('Occi::Core::Kind') }

      let(:mixin) do
        Mixin.new(
          term: example_term,
          schema: example_schema,
          title: example_title,
          depends: [second_mixin],
          applies: [kind_double]
        )
      end

      let(:second_mixin) do
        Mixin.new(
          term: 'second_mixin',
          schema: 'http://schema.test.opr/test#',
          title: 'Second mixin'
        )
      end

      MIXIN_ATTRS = [:actions, :depends, :applies, :location].freeze

      MIXIN_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      describe '#depends?' do
        it 'returns `false` without passing a mixin' do
          expect(subject.depends?(nil)).to be false
        end

        it 'returns `false` without dependency' do
          expect(second_mixin.depends?(mixin)).to be false
        end

        it 'returns `true` with dependency' do
          expect(subject.depends?(second_mixin)).to be true
        end
      end

      describe '#applies?' do
        it 'returns `false` without passing a kind' do
          expect(subject.applies?(nil)).to be false
        end

        it 'returns `false` without applicability' do
          expect(second_mixin.applies?(kind_double)).to be false
        end

        it 'returns `true` with applicability' do
          expect(subject.applies?(kind_double)).to be true
        end
      end
    end
  end
end
