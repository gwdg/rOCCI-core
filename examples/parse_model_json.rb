require 'occi/infrastructure'

Yell.new '/dev/null', name: Object

model = Occi::Infrastructure::Model.new

mf = File.read File.join(File.dirname(__FILE__), 'rendering', 'model.json')
Occi::Core::Parsers::JsonParser.model(mf, {}, 'application/json', model)
model.valid!
