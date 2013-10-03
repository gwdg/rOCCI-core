require 'rubygems'

# enable coverage reports
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.add_filter "/spec/"
  SimpleCov.start
end

require 'occi-core'

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
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
