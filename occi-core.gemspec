# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'occi/version'

Gem::Specification.new do |gem|
  gem.name          = 'occi-core'
  gem.version       = Occi::VERSION
  gem.authors       = ['Florian Feldhaus','Piotr Kasprzak', 'Boris Parak']
  gem.email         = ['florian.feldhaus@gmail.com', 'piotr.kasprzak@gwdg.de', 'xparak@mail.muni.cz']
  gem.description   = %q{OCCI is a collection of classes to simplify the implementation of the Open Cloud Computing API in Ruby}
  gem.summary       = %q{OCCI toolkit}
  gem.homepage      = 'https://github.com/gwdg/rOCCI-core'
  gem.license       = 'Apache License, Version 2.0'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.require_paths = ['lib']

  gem.add_dependency 'json'
  gem.add_dependency 'hashie'
  gem.add_dependency 'uuidtools', '>=2.1.3'
  gem.add_dependency 'activesupport', '~>4.0.0'
  gem.add_dependency 'settingslogic'

  gem.required_ruby_version     = '>= 1.9.3'
end
