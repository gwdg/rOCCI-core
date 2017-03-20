require 'rubygems'

# enable coverage reports
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.add_filter '/spec/'
  SimpleCov.start
end

require 'occi/core'
require 'occi/infrastructure'

Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelled names.
    mocks.verify_doubled_constant_names = true
  end
end
