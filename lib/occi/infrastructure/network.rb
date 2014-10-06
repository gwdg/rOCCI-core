module Occi
  module Infrastructure
    class Network < Occi::Core::Resource

      up = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/network/action#',
                                  term='up',
                                  title='activate network'

      down = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/network/action#',
                                    term='down',
                                    title='deactivate network'

      self.actions = Occi::Core::Actions.new << up << down

      self.attributes = Occi::Core::Attributes.new(Occi::Core::Resource.attributes)
      self.attributes['occi.network.vlan'] = {:type => 'number',
                                              :mutable => true,
                                              :pattern => '\d+'}
      self.attributes['occi.network.label'] = {:type => 'string',
                                               :mutable => true}
      self.attributes['occi.network.state'] ={:type => 'string',
                                              :pattern => 'active|inactive|error',
                                              :default => 'inactive',
                                              :mutable => false}

      self.kind = Occi::Core::Kind.new scheme='http://schemas.ogf.org/occi/infrastructure#',
                                       term='network',
                                       title = 'network resource',
                                       attributes=Occi::Core::Attributes.new(self.attributes),
                                       parent=Occi::Core::Resource.kind,
                                       actions = Occi::Core::Actions.new(self.actions),
                                       location = '/network/'

      require 'occi/infrastructure/network/ipnetwork'
      self.mixins = Occi::Core::Mixins.new << Occi::Infrastructure::Network::Ipnetwork.mixin

      def ipnetwork(add = true)
        if add
          Occi::Log.info "[#{self.class}] Adding mixin IPNetwork"
          @mixins << Occi::Infrastructure::Network::Ipnetwork.mixin
        else
          Occi::Log.info "[#{self.class}] Removing mixin IPNetwork"
          @mixins.delete Occi::Infrastructure::Network::Ipnetwork.mixin
        end
      end

      def vlan
        @attributes.occi_.network_.vlan
      end

      def vlan=(vlan)
        @attributes.occi!.network!.vlan = vlan
      end

      def label
        @attributes.occi_.network_.label
      end

      def label=(label)
        @attributes.occi!.network!.label = label
      end

      def state
        @attributes.occi_.network_.state
      end

      def state=(state)
        @attributes.occi!.network!.state = state
      end

      # IPNetwork Mixin attributes

      def address
        @attributes.occi_.network_.address
      end

      def address=(address)
        add_ipnetwork_mixin
        @attributes.occi!.network!.address = address
      end

      def gateway
        @attributes.occi_.network_.gateway
      end

      def gateway=(gateway)
        add_ipnetwork_mixin
        @attributes.occi!.network!.gateway = gateway
      end

      def allocation
        @attributes.occi_.network_.allocation
      end

      def allocation=(allocation)
        add_ipnetwork_mixin
        @attributes.occi!.network!.allocation = allocation
      end

      private

      def add_ipnetwork_mixin
        ipnetwork(true) if @mixins.select { |mixin| mixin.type_identifier == Occi::Infrastructure::Network::Ipnetwork.mixin.type_identifier }.empty?
      end

    end
  end
end
