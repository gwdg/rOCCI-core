module Occi
  module Core
    describe Locations do
      subject(:locs) { locations }

      let(:locations) { Locations.new(uris: uris) }
      let(:uris) do
        Set.new(
          [
            URI.parse('/compute/1'),
            URI.parse('/compute/2')
          ]
        )
      end
      let(:invalid_uri) { '/comput e/12' }

      LOCS_ATTRS = %i[uris].freeze

      LOCS_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      it 'has logger' do
        expect(locs).to respond_to(:logger)
        expect(locs.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(locs).to be_kind_of(Helpers::Renderable)
        expect(locs).to respond_to(:render)
      end

      it 'is enumerable' do
        expect(locs).to be_kind_of(Enumerable)
        expect(locs).to respond_to(:each)
      end

      LOCS_DELEG = %i[<< add remove map! empty? include?].freeze
      LOCS_DELEG.each do |mtd|
        it "delegates #{mtd} to uris" do
          expect(locs).to respond_to(mtd)
        end
      end

      describe '::new' do
        it 'creates an instance without args' do
          expect { Locations.new }.not_to raise_error
        end

        it 'creates an instance with args' do
          expect(locs).not_to be_empty
        end

        it 'fails to create an instance with explicitly `nil` uris' do
          expect { Locations.new(uris: nil) }.to raise_error(Occi::Core::Errors::MandatoryArgumentError)
        end
      end

      describe '#host=' do
        let(:host) { 'localhost' }

        it 'assigns host to all uris' do
          expect { locs.host = host }.not_to raise_error
          locs.each { |loc| expect(loc.host).to eq host }
        end
      end

      describe '#port=' do
        let(:port) { 1243 }

        it 'assigns port to all uris' do
          expect { locs.port = port }.not_to raise_error
          locs.each { |loc| expect(loc.port).to eq port }
        end
      end

      describe '#scheme=' do
        let(:scheme) { 'https' }

        it 'assigns scheme to all uris' do
          expect { locs.scheme = scheme }.not_to raise_error
          locs.each { |loc| expect(loc.scheme).to eq scheme }
        end
      end

      describe '#valid?' do
        it 'passes on valid uris' do
          expect(locs.valid?).to be true
        end

        it 'fails on invalid uris' do
          locs << invalid_uri
          expect(locs.valid?).to be false
        end
      end

      describe '#valid!' do
        it 'passes on valid uris' do
          expect { locs.valid! }.not_to raise_error
        end

        it 'fails on invalid uris' do
          locs << invalid_uri
          expect { locs.valid! }.to raise_error(Occi::Core::Errors::LocationValidationError)
        end
      end
    end
  end
end
