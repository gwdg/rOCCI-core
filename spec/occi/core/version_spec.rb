module Occi
  module Core
    describe Core do
      it 'publishes full version string' do
        expect(defined?(VERSION)).to be_truthy
        expect(VERSION).not_to be_empty
      end

      it 'published well-formed full version string' do
        expect(VERSION).to match "#{MAJOR_VERSION}.#{MINOR_VERSION}.#{PATCH_VERSION}" \
                                 "#{STAGE_VERSION ? '.' + STAGE_VERSION : ''}"
      end

      it 'publishes major version string' do
        expect(defined?(MAJOR_VERSION)).to be_truthy
        expect(MAJOR_VERSION).not_to be_nil
      end

      it 'publishes minor version string' do
        expect(defined?(MINOR_VERSION)).to be_truthy
        expect(MINOR_VERSION).not_to be_nil
      end

      it 'publishes patch version string' do
        expect(defined?(PATCH_VERSION)).to be_truthy
        expect(PATCH_VERSION).not_to be_nil
      end

      it 'publishes stage version string' do
        expect(defined?(STAGE_VERSION)).to be_truthy
      end
    end
  end
end
