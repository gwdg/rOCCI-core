module Occi
  module Infrastructure
    module OsTpl

      mattr_accessor :attributes, :mixin

      self.attributes = Occi::Core::Attributes.new

      self.mixin = Occi::Core::Mixin.new scheme='http://schemas.ogf.org/occi/infrastructure#',
                                         term='os_tpl',
                                         title='operating system template',
                                         attributes=Occi::Core::Attributes.new(self.attributes),
                                         dependencies=Occi::Core::Dependencies.new,
                                         actions=Occi::Core::Actions.new,
                                         location='/mixin/os_tpl/',
                                         applies=Occi::Core::Kinds.new << Occi::Infrastructure::Compute.kind
    end

  end
end
