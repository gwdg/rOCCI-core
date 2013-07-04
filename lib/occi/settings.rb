module Occi
  class Settings < Settingslogic
    source 'config/occi.yml'
    source open(ENV['HOME']+'/.occi') if File.file?(ENV['HOME']+'/.occi')
    namespace 'core'
  end
end