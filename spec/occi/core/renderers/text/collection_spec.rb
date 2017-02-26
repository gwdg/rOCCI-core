module Occi
  module Core
    module Renderers
      module Text
        describe Collection do
          subject(:collr) { collection_renderer }

          let(:empty_collection) { Occi::Core::Collection.new }
          let(:options) { { format: 'text' } }
          let(:collection_renderer) { Collection.new(empty_collection, options) }

          BASE_ATTRS = [:object, :options].freeze
          BASE_ATTRS.each do |attr|
            it "has #{attr} accessor" do
              is_expected.to have_attr_accessor attr.to_sym
            end
          end

          it 'has logger' do
            expect(collr).to respond_to(:logger)
            expect(collr.class).to respond_to(:logger)
          end

          describe '#render' do
            it 'does something'
          end
        end
      end
    end
  end
end
