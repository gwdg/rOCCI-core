require 'occi/infrastructure-ext'

Yell.new :stdout, name: Object

model = Occi::InfrastructureExt::Model.new
model.load_core!
model.load_infrastructure!
model.load_infrastructure_ext!

model.valid!

puts model.to_text
