# external deps
require 'active_support/all'

# TODO: docs
module Occi
  # TODO: docs
  module Core
    autoload :AttributeDefinition, 'occi/core/attribute_definition'
    autoload :AttributeDefinitions, 'occi/core/attribute_definitions'

    autoload :Category, 'occi/core/category'
    autoload :Kind, 'occi/core/kind'
    autoload :Action, 'occi/core/action'
    autoload :Mixin, 'occi/core/mixin'
  end
end

require 'occi/core/version'
