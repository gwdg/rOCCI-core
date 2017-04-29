require 'occi/infrastructure'

Yell.new '/dev/null', name: Object

model = Occi::Infrastructure::Model.new
model.load_core!
model.load_infrastructure!

mf = File.read File.join(File.dirname(__FILE__), 'rendering', 'model.txt')
Occi::Core::Parsers::TextParser.model(mf, {}, 'text/plain', model)

model.valid!

parser = Occi::Core::Parsers::TextParser.new(model: model, media_type: 'text/plain')
cf = File.read File.join(File.dirname(__FILE__), 'rendering', 'compute.txt')

compute = parser.entities(cf, {}).first
compute.valid!

puts compute.to_text
