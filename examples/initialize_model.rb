require 'occi/infrastructure-ext'

Yell.new '/dev/null', name: Object

model = Occi::InfrastructureExt::Model.new
model.load_core!
model.load_infrastructure!
model.load_infrastructure_ext!

model.valid!
