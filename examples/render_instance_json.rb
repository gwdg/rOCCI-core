require 'occi/infrastructure-ext'

Yell.new '/dev/null', name: Object

model = Occi::InfrastructureExt::Model.new
model.load_core!
model.load_infrastructure!
model.load_infrastructure_ext!

model.valid!

compute = model.instance_builder.get Occi::Infrastructure::Constants::COMPUTE_KIND
compute.identify!
compute.title = 'My Compute Instance'
compute['occi.compute.cores']  = 4
compute['occi.compute.memory'] = 2.0

compute.valid!

puts compute.to_json
