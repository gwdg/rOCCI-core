# external deps
require 'active_support/all'
require 'uri'
require 'yaml'
require 'ipaddr'
require 'singleton'
require 'yell'
require 'json'
require 'json-schema'

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
    autoload :Constants, 'occi/core/constants'
    autoload :Errors, 'occi/core/errors'
    autoload :Renderers, 'occi/core/renderers'
    autoload :Helpers, 'occi/core/helpers'
    autoload :Parsers, 'occi/core/parsers'
    autoload :RendererFactory, 'occi/core/renderer_factory'

    autoload :AttributeDefinition, 'occi/core/attribute_definition'
    autoload :Category, 'occi/core/category'
    autoload :Kind, 'occi/core/kind'
    autoload :Action, 'occi/core/action'
    autoload :Mixin, 'occi/core/mixin'

    autoload :Attribute, 'occi/core/attribute'
    autoload :ActionInstance, 'occi/core/action_instance'
    autoload :Entity, 'occi/core/entity'
    autoload :Link, 'occi/core/link'
    autoload :Resource, 'occi/core/resource'

    autoload :Collection, 'occi/core/collection'
    autoload :Model, 'occi/core/model'
    autoload :Warehouse, 'occi/core/warehouse'
    autoload :InstanceBuilder, 'occi/core/instance_builder'
  end
end

# Explicitly load monkey patches
require 'occi/monkey_island/boolean'
require 'occi/monkey_island/hash'

# Explicitly pull in versioning information
require 'occi/core/version'
