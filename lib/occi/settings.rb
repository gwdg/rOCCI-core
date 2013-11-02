module Occi
  class Settings < Settingslogic
    gem_root = File.expand_path '../../..', __FILE__

    source "#{ENV['HOME']}/.occi" if File.readable?("#{ENV['HOME']}/.occi")
    source "#{gem_root}/config/occi.yml"

    namespace 'core'
  end
end
