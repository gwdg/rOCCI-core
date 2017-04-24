require 'occi/infrastructure'

Yell.new :stdout, name: Object

model = Occi::Infrastructure::Model.new
model.load_core!
model.load_infrastructure!

model.valid!

puts model.to_text
