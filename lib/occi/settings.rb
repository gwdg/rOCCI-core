module Occi
  class Settings < Settingslogic
    gem_root = File.expand_path '../../..', __FILE__

    source "#{gem_root}/config/occi.yml"
    source open(ENV['HOME']+'/.occi') if File.file?(ENV['HOME']+'/.occi')
    namespace 'core'
  end
end
