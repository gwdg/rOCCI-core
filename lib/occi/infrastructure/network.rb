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
                                              :pattern => 'x86|x64'}
      self.attributes['occi.network.label'] = {:type => 'number',
                                               :mutable => true}
      self.attributes['occi.network.state'] ={:pattern => 'active|inactive|error',
                                              :default => 'inactive'}

      self.kind = Occi::Core::Kind.new scheme='http://schemas.ogf.org/occi/infrastructure#',
                                       term='network',
                                       title = 'network resource',
                                       attributes=self.attributes,
                                       parent=Occi::Core::Resource.kind,
                                       actions = self.actions,
                                       location = '/network/'

      require 'occi/infrastructure/network/ipnetwork'
      self.mixins = Occi::Core::Mixins.new << Occi::Infrastructure::Network::Ipnetwork.mixin

      def ipnetwork(boolean=true)
        if boolean
          mixins << Occi::Infrastructure::Network::Ipnetwork.mixin.type_identifier
        else
          mixins.delete Occi::Infrastructure::Network::Ipnetwork.mixin.type_identifier
        end
      end

      def vlan
        @attributes.occi_.nework_.vlan
      end

      def vlan=(vlan)
        @attributes.occi!.network!.vlan = vlan
      end

      def label
        @attributes.occi_.nework_.label
      end

      def label=(label)
        @attributes.occi!.network!.label = label
      end

      def state
        @attributes.occi_.nework_.state
      end

      def state=(state)
        @attributes.occi!.network!.state = state
      end

      # IPNetwork Mixin attributes

      def address
        @attributes.occi_.network_.address
      end

      def address=(address)
        if @mixins.select { |mixin| mixin.kind_of? Occi::Infrastructure::Network::Ipnetwork }.empty?
          Occi::Log.info 'Adding mixin IPNetwork mixin'
          @mixins << Occi::Infrastructure::Network::Ipnetwork.new
        end
        @attributes.occi!.network!.address = address
      end

      def gateway
        @attributes.occi_.network_.gateway
      end

      def gateway=(gateway)
        if @mixins.select { |mixin| mixin.kind_of? Occi::Infrastructure::Network::Ipnetwork }.empty?
          Occi::Log.info 'Adding mixin IP network'
          @mixins << Occi::Infrastructure::Network::Ipnetwork.new
        end
        @attributes.occi!.network!.gateway = gateway
      end

      def allocation
        @attributes.occi_.network_.allocation
      end

      def allocation=(allocation)
        if @mixins.select { |mixin| mixin.kind_of? Occi::Infrastructure::Network::Ipnetwork }.empty?
          Occi::Log.info 'Adding mixin IPNetwork mixin'
          @mixins << Occi::Infrastructure::Network::Ipnetwork.new
        end
        @attributes.occi!.network!.allocation = allocation
      end

    end
  end
end