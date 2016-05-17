lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'occi/core/version'

Gem::Specification.new do |gem|
  gem.name          = 'occi-core'
  gem.version       = Occi::Core::VERSION
  gem.authors       = ['Boris Parak', 'Florian Feldhaus', 'Piotr Kasprzak']
  gem.email         = ['parak@cesnet.cz', 'florian.feldhaus@gmail.com', 'piotr.kasprzak@gwdg.de']
  gem.description   = %q{The rOCCI toolkit is a collection of classes simplifying implementation of Open Cloud Computing Interface in Ruby}
  gem.summary       = %q{The rOCCI toolkit}
  gem.homepage      = 'https://github.com/EGI-FCTF/rOCCI-core'
  gem.license       = 'Apache License, Version 2.0'

  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'ox', '~> 2.4'
  gem.add_runtime_dependency 'oj', '~> 2.15'
  gem.add_runtime_dependency 'uuidtools', '~> 2.1'
  gem.add_runtime_dependency 'activesupport', '~> 4.0'
  gem.add_runtime_dependency 'json-schema', '~> 2.5'
  gem.add_runtime_dependency 'yell', '~> 2.0'

  gem.add_development_dependency 'bundler', '~> 1.12'
  gem.add_development_dependency 'rake', '~> 11.0'
  gem.add_development_dependency 'rspec', '~> 3.4'
  gem.add_development_dependency 'simplecov', '~> 0.11'
  gem.add_development_dependency 'pry', '~> 0.10'
  gem.add_development_dependency 'rubocop', '~> 0.32'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'

  gem.required_ruby_version = '>= 1.9.3'
end
