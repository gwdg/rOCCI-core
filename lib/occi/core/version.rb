module Occi
  module Core
    MAJOR_VERSION = 5                # Major update constant
    MINOR_VERSION = 0                # Minor update constant
    PATCH_VERSION = 0                # Patch/Fix version constant
    STAGE_VERSION = 'beta.8'.freeze # use `nil` for production releases

    unless defined?(::Occi::Core::VERSION)
      VERSION = [
        MAJOR_VERSION,
        MINOR_VERSION,
        PATCH_VERSION,
        STAGE_VERSION
      ].compact.join('.').freeze
    end
  end
end
