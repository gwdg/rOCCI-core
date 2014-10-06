module Occi
  module Infrastructure
    class Storagelink < Occi::Core::Link

      online = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storagelink/action#',
                                      term='online',
                                      title='activate storagelink'

      offline = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/storagelink/action#',
                                       term='offline',
                                       title='deactivate storagelink'

      self.actions = Occi::Core::Actions.new << online << offline

      self.attributes = Occi::Core::Attributes.new(Occi::Core::Link.attributes)
      self.attributes['occi.storagelink.deviceid'] = {:mutable => true}
      self.attributes['occi.storagelink.mountpoint'] = {:mutable => true}
      self.attributes['occi.storagelink.state'] = {:type => 'string',
                                                   :pattern => 'active|inactive|error',
                                                   :default => 'inactive',
                                                   :mutable => false}

      self.kind = Occi::Core::Kind.new scheme='http://schemas.ogf.org/occi/infrastructure#',
                                       term='storagelink',
                                       title = 'storage link',
                                       attributes = Occi::Core::Attributes.new(self.attributes),
                                       parent=Occi::Core::Link.kind,
                                       actions = Occi::Core::Actions.new(self.actions),
                                       location = '/link/storagelink/'


      def deviceid
        @attributes.occi_.storagelink_.deviceid
      end

      def deviceid=(deviceid)
        @attributes.occi!.storagelink!.deviceid = deviceid
      end

      def mountpoint
        @attributes.occi_.storagelink_.mountpoint
      end

      def mountpoint=(mountpoint)
        @attributes.occi!.storagelink!.mountpoint = mountpoint
      end

      def state
        @attributes.occi_.storagelink_.state
      end

      def state=(state)
        @attributes.occi!.storagelink!.state = state
      end

    end
  end
end
