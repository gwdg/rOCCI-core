# Wrapper for all custom error classes. For details on intended
# use, see specific error classes within this module.
module Occi::Core::Errors; end

Dir[File.join(File.dirname(__FILE__), 'errors', '*.rb')].each { |file| require file.gsub('.rb', '') }
