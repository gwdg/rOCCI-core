module Occi
  module Infrastructure
    class Networkinterface < Occi::Core::Link

      up = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/networkinterface/action#',
                                  term='up',
                                  title='activate networkinterface'

      down = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/networkinterface/action#',
                                    term='down',
                                    title='deactivate networkinterface'

      self.actions = Occi::Core::Actions.new << up << down

      self.attributes = Occi::Core::Attributes.new(Occi::Core::Link.attributes)
      self.attributes['occi.networkinterface.interface'] = {:mutable => false}
      self.attributes['occi.networkinterface.mac'] = {:mutable => true,
                                                      :pattern => '^([0-9a-fA-F]{2}[:-]){5}([0-9a-fA-F]{2})$'}
      self.attributes['occi.networkinterface.state'] = {:type => 'string',
                                                        :pattern => 'active|inactive|error',
                                                        :default => 'inactive',
                                                        :mutable => false}

      self.kind = Occi::Core::Kind.new scheme='http://schemas.ogf.org/occi/infrastructure#',
                                       term='networkinterface',
                                       title = 'networkinterface link',
                                       attributes = Occi::Core::Attributes.new(self.attributes),
                                       parent = Occi::Core::Link.kind,
                                       actions = Occi::Core::Actions.new(self.actions),
                                       location = '/link/networkinterface/'

      require 'occi/infrastructure/networkinterface/ipnetworkinterface'
      self.mixins = Occi::Core::Mixins.new << Occi::Infrastructure::Networkinterface::Ipnetworkinterface.mixin

      def ipnetworkinterface(add = true)
        if add
          Occi::Log.info "[#{self.class}] Adding mixin IPNetworkInterface"
          @mixins << Occi::Infrastructure::Networkinterface::Ipnetworkinterface.mixin
        else
          Occi::Log.info "[#{self.class}] Removing mixin IPNetworkInterface"
          @mixins.delete Occi::Infrastructure::Networkinterface::Ipnetworkinterface.mixin
        end
      end

      def interface
        @attributes.occi_.networkinterface_.interface
      end

      def interface=(interface)
        @attributes.occi!.networkinterface!.interface = interface
      end

      def mac
        @attributes.occi_.networkinterface_.mac
      end

      def mac=(mac)
        @attributes.occi!.networkinterface!.mac = mac
      end

      def state
        @attributes.occi_.networkinterface_.state
      end

      def state=(state)
        @attributes.occi!.networkinterface!.state = state
      end

      def address
        @attributes.occi_.networkinterface_.address
      end

      def address=(address)
        add_ipnetworkinterface_mixin
        @attributes.occi!.networkinterface!.address = address
      end

      def gateway
        @attributes.occi_.networkinterface_.gateway
      end

      def gateway=(gateway)
        add_ipnetworkinterface_mixin
        @attributes.occi!.networkinterface!.gateway = gateway
      end

      def allocation
        @attributes.occi_.networkinterface_.allocation
      end

      def allocation=(allocation)
        add_ipnetworkinterface_mixin
        @attributes.occi!.networkinterface!.allocation = allocation
      end

      private

      def add_ipnetworkinterface_mixin
        ipnetworkinterface(true) if @mixins.select { |mixin| mixin.type_identifier == Occi::Infrastructure::Networkinterface::Ipnetworkinterface.mixin.type_identifier }.empty?
      end

    end
  end
end
