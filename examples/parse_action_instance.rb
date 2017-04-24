require 'occi/infrastructure'

Yell.new :stdout, name: Object

model = Occi::Infrastructure::Model.new
model.load_core!
model.load_infrastructure!

model.valid!

parser = Occi::Core::Parsers::TextParser.new(model: model, media_type: 'text/plain')
aif = File.read File.join(File.dirname(__FILE__), 'rendering', 'action_instance.txt')

ai = parser.action_instances(aif, {}).first
ai.valid!

puts ai.to_text
