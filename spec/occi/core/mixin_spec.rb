module Occi
  module Core
    describe Mixin do
      subject(:mxn) { mixin }

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
          expect(mxn.depends?(nil)).to be false
        end

        it 'returns `false` without dependency' do
          expect(second_mixin.depends?(mixin)).to be false
        end

        it 'returns `true` with dependency' do
          expect(mxn.depends?(second_mixin)).to be true
        end
      end

      describe '#applies?' do
        it 'returns `false` without passing a kind' do
          expect(mxn.applies?(nil)).to be false
        end

        it 'returns `false` without applicability' do
          expect(second_mixin.applies?(kind_double)).to be false
        end

        it 'returns `true` with applicability' do
          expect(mxn.applies?(kind_double)).to be true
        end
      end

      describe '#location' do
        context 'without term and location' do
          before(:example) do
            mxn.term = nil
            mxn.location = nil
          end

          it 'fails' do
            expect { mxn.location }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
          end
        end

        context 'with term and without location' do
          before(:example) { mxn.location = nil }

          it 'returns default' do
            expect(mxn.location).to be_kind_of URI
          end
        end
      end
    end
  end
end
