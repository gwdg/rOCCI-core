# :nodoc:
module Occi
  # :nodoc:
  module Core
    MAJOR_VERSION = 5
    MINOR_VERSION = 0
    PATCH_VERSION = 0
    STAGE_VERSION = 'alpha.1'.freeze # use `nil` for production releases

    unless defined?(::Occi::Core::VERSION)
      VERSION = [
        MAJOR_VERSION,
        MINOR_VERSION,
        PATCH_VERSION,
        STAGE_VERSION
      ].compact.join('.')
    end
  end
end
