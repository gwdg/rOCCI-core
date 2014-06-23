require 'rubygems'

# enable coverage reports
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.add_filter "/spec/"
  SimpleCov.start
end

require 'occi-core'
require 'json_spec'

Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each {|file| require file }

# simplify the usage of VCR; this will allow us to use
#
#   it "does something", :vcr do
#     ...
#   end
#
# instead of
#
#   it "does something else", :vcr => true do
#     ...
#   end
RSpec.configure do |c|
  c.include JsonSpec::Helpers
end
