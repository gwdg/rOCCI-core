# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'occi/version'

Gem::Specification.new do |gem|
  gem.name          = 'occi-core'
  gem.version       = Occi::VERSION
  gem.authors       = ['Florian Feldhaus','Piotr Kasprzak', 'Boris Parak']
  gem.email         = ['florian.feldhaus@gmail.com', 'piotr.kasprzak@gwdg.de', 'parak@cesnet.cz']
  gem.description   = %q{OCCI is a collection of classes to simplify the implementation of the Open Cloud Computing API in Ruby}
  gem.summary       = %q{OCCI toolkit}
  gem.homepage      = 'https://github.com/EGI-FCTF/rOCCI-core'
  gem.license       = 'Apache License, Version 2.0'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.require_paths = ['lib']

  gem.add_dependency 'json', '>= 1.8.1', '< 3'
  gem.add_dependency 'hashie', '>= 3.3.1', '< 3.5'
  gem.add_dependency 'uuidtools', '>= 2.1.3', '< 3'
  gem.add_dependency 'activesupport', '>= 4.0.0', '< 6'
  gem.add_dependency 'settingslogic', '>= 2.0.9', '< 3'

  gem.add_development_dependency 'rubygems-tasks', '>= 0.2.4', '< 1'
  gem.add_development_dependency 'json_spec', '>= 1.1.4', '< 2'
  gem.add_development_dependency 'rspec', '>= 3.5.0', '< 4'
  gem.add_development_dependency 'rake', '>= 12', '< 13'
  gem.add_development_dependency 'builder', '>= 3.2.3', '< 4'
  gem.add_development_dependency 'simplecov', '>= 0.13', '< 1'
  gem.add_development_dependency 'yard', '>= 0.9.8', '< 1'
  gem.add_development_dependency 'yard-rspec', '>= 0.1', '< 1'
  gem.add_development_dependency 'pry', '>= 0.10.4', '< 1'

  gem.required_ruby_version = '>= 1.9.3'
end
