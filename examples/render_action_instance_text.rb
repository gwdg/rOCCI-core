require 'occi/infrastructure-ext'

Yell.new '/dev/null', name: Object

model = Occi::InfrastructureExt::Model.new
model.load_core!
model.load_infrastructure!
model.load_infrastructure_ext!

model.valid!

ai = Occi::Core::ActionInstance.new(
  action: model.actions.first
)
ai.valid!

puts ai.to_text
