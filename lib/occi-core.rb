require 'rubygems'

require 'active_support'
require 'active_support/core_ext'
require 'active_support/json'
require 'active_support/inflector'
require 'active_support/notifications'

require 'set'
require 'uri'
require 'hashie/mash'

require 'logger'
require 'uuidtools'
require 'rubygems/package'
require 'zlib'
require 'tempfile'
require 'settingslogic'

require 'occi/extensions/hashie'

require 'occi/helpers/inspect'
require 'occi/helpers/comparators'

require 'occi/errors'
require 'occi/settings'
require 'occi/log'
require 'occi/version'
require 'occi/core'
require 'occi/infrastructure'
require 'occi/collection'
require 'occi/parser'
require 'occi/model'

module Occi

  def kinds
    Occi::Core::Kinds.new
  end

  def mixins
    Occi::Core::Mixins.new
  end

  def actions
    Occi::Core::Actions.new
  end

  # @return [Array] list of Occi::Core::Categories
  def categories
    self.kinds + self.mixins + self.actions
  end
end
