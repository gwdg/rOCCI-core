require 'occi/infrastructure'

Yell.new :stdout, name: Object

model = Occi::Infrastructure::Model.new
model.load_core!
model.load_infrastructure!

model.valid!

parser = Occi::Core::Parsers::TextParser.new(model: model, media_type: 'text/plain')
cf = File.read File.join(File.dirname(__FILE__), 'rendering', 'compute.txt')

compute = parser.entities(cf, {}).first
compute.valid!

puts compute.to_text
