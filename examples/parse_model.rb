require 'occi/infrastructure'

Yell.new '/dev/null', name: Object

model = Occi::Infrastructure::Model.new

mf = File.read File.join(File.dirname(__FILE__), 'rendering', 'model.txt')
Occi::Core::Parsers::TextParser.model(mf, {}, 'text/plain', model)
model.valid!

puts model.to_text
