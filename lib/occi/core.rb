# external deps
require 'active_support/all'
require 'uri'
require 'yell'

# Contains all OCCI-related classes and modules. This module
# does not provide any additional functionality aside from
# acting as a wrapper and a namespace-defining mechanisms.
# Please, defer to specific classes and modules within this
# namespace for details and functionality descriptions.
#
# @author Boris Parak <parak@cesnet.cz>
module Occi
  # Contains all OCCI-Core-related classes and modules. This
  # module does not provide any additional functionality aside
  # from acting as a wrapped, a namespace-defining mechanism,
  # and versioning wrapper. Please, defer to specific classes
  # and modules within this namespace for details and
  # functionality descriptions.
  #
  # @example
  #   Occi::Core::VERSION       # => '5.0.0.alpha.1'
  #   Occi::Core::MAJOR_VERSION # => 5
  #   Occi::Core::MINOR_VERSION # => 0
  #   Occi::Core::PATCH_VERSION # => 0
  #   Occi::Core::STAGE_VERSION # => 'alpha.1'
  #
  # @author Boris Parak <parak@cesnet.cz>
  module Core
    autoload :Errors, 'occi/core/errors'

    # Contains all rendering-related classes and modules. This
    # module houses functionality transforming various internal
    # instances to standardized over-the-wire renderings. In most
    # cases, it is not intended to be called explicitly. Its
    # instrumentation will be used automatically by selected
    # instances when calling `render` or `to_<format>`.
    #
    # This is also the place where additional rendering formats
    # should be added. Please, refer to internal documentation
    # for details on how to add a new rendering format.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Rendering
      autoload :Renderable, 'occi/core/rendering/renderable'
    end

    autoload :AttributeDefinition, 'occi/core/attribute_definition'

    autoload :Category, 'occi/core/category'
    autoload :Kind, 'occi/core/kind'
    autoload :Action, 'occi/core/action'
    autoload :Mixin, 'occi/core/mixin'

    autoload :Attribute, 'occi/core/attribute'
  end
end

# Explicitly pull in versioning information
require 'occi/core/version'
