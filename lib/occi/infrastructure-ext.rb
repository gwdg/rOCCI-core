# internal deps
require 'occi/infrastructure'

# Contains all OCCI-related classes and modules. This module
# does not provide any additional functionality aside from
# acting as a wrapper and a namespace-defining mechanisms.
# Please, defer to specific classes and modules within this
# namespace for details and functionality descriptions.
#
# @author Boris Parak <parak@cesnet.cz>
module Occi
  # Contains all OCCI-Infra-Ext-related classes and modules. This
  # module does not provide any additional functionality aside
  # from acting as a wrapped, a namespace-defining mechanism,
  # and versioning wrapper. Please, defer to specific classes
  # and modules within this namespace for details and
  # functionality descriptions.
  #
  # @author Boris Parak <parak@cesnet.cz>
  module InfrastructureExt
    autoload :Constants, 'occi/infrastructure_ext/constants'
    autoload :Mixins, 'occi/infrastructure_ext/mixins'

    autoload :SecurityGroup, 'occi/infrastructure_ext/securitygroup'
    autoload :IPReservation, 'occi/infrastructure_ext/ipreservation'
    autoload :SecurityGroupLink, 'occi/infrastructure_ext/securitygrouplink'

    autoload :Model, 'occi/infrastructure_ext/model'
    autoload :Warehouse, 'occi/infrastructure_ext/warehouse'
    autoload :InstanceBuilder, 'occi/infrastructure_ext/instance_builder'
  end
end

# Explicitly pull in versioning information
require 'occi/infrastructure_ext/version'
