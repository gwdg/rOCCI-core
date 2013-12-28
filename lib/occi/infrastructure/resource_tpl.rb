module Occi
  module Infrastructure
    module ResourceTpl

      mattr_accessor :attributes, :mixin

      self.attributes = Occi::Core::Attributes.new

      self.mixin = Occi::Core::Mixin.new scheme='http://schemas.ogf.org/occi/infrastructure#',
                                         term='resource_tpl',
                                         title='resource template',
                                         attributes=Occi::Core::Attributes.new(self.attributes),
                                         related=Occi::Core::Categories.new << Occi::Infrastructure::Compute.kind,
                                         actions=Occi::Core::Actions.new,
                                         location='/mixin/resource_tpl/'
    end

  end
end
