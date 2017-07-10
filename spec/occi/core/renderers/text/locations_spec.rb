module Occi
  module Core
    module Renderers
      module Text
        describe Locations do
          subject(:lsr) { locations_renderer }

          let(:uris) do
            Set.new(
              [
                URI.parse('/compute/1'),
                URI.parse('/compute/2')
              ]
            )
          end

          let(:object) { ::Occi::Core::Locations.new(uris: uris) }
          let(:options) { { format: 'text' } }
          let(:locations_renderer) { Locations.new(object, options) }

          %i[object options].each do |attr|
            it "has #{attr} accessor" do
              is_expected.to have_attr_accessor attr.to_sym
            end
          end

          it 'has logger' do
            expect(lsr).to respond_to(:logger)
            expect(lsr.class).to respond_to(:logger)
          end

          describe '#render' do
            context 'with uris' do
              it 'renders to text' do
                expect(lsr.render).to eq "X-OCCI-Location: /compute/1\nX-OCCI-Location: /compute/2"
              end

              it 'renders to headers' do
                lsr.options = { format: 'headers' }
                expect(lsr.render).to eq('Location' => ['/compute/1', '/compute/2'])
              end
            end

            context 'without uris' do
              let(:object) { ::Occi::Core::Locations.new }

              it 'renders to text' do
                expect(lsr.render).to be_empty
              end

              it 'renders to headers' do
                lsr.options = { format: 'headers' }
                expect(lsr.render).to eq({})
              end
            end
          end
        end
      end
    end
  end
end
