module Occi
  module Infrastructure
    class Compute < Occi::Core::Resource

      start = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#',
                                     term='start',
                                     title='start compute instance'

      stop = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#',
                                    term='stop',
                                    title='stop compute instance'
      stop.attributes['method'] = {:mutable => true,
                                   :pattern => 'graceful|acpioff|poweroff',
                                   :default => 'poweroff'}

      restart = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#',
                                       term='restart',
                                       title='restart compute instance'
      restart.attributes['method'] = {:mutable => true,
                                      :pattern => 'graceful|warm|cold',
                                      :default => 'cold'}

      suspend = Occi::Core::Action.new scheme='http://schemas.ogf.org/occi/infrastructure/compute/action#',
                                       term='suspend',
                                       title='suspend compute instance'
      suspend.attributes['method'] = {:mutable => true,
                                     :pattern => 'hibernate|suspend',
                                     :default => 'suspend'}

      self.actions = Occi::Core::Actions.new << start << stop << restart << suspend

      self.attributes = Occi::Core::Attributes.new(Occi::Core::Resource.attributes)
      self.attributes['occi.compute.architecture'] = {:mutable => true,
                                                      :pattern => 'x86|x64'}
      self.attributes['occi.compute.cores'] = {:type => 'number',
                                               :mutable => true}
      self.attributes['occi.compute.hostname'] = {:mutable => true,
                                                  :pattern => '(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*'}
      self.attributes['occi.compute.memory'] = {:type => 'number',
                                                :mutable => true}
      self.attributes['occi.compute.speed'] = {:type => 'number',
                                                :mutable => true}
      self.attributes['occi.compute.state'] = {:type => 'string',
                                               :pattern => 'inactive|active|suspended|error',
                                               :default => 'inactive',
                                               :mutable => false}

      self.kind = Occi::Core::Kind.new scheme='http://schemas.ogf.org/occi/infrastructure#',
                                       term='compute',
                                       title = 'compute resource',
                                       attributes=Occi::Core::Attributes.new(self.attributes),
                                       parent=Occi::Core::Resource.kind,
                                       actions = Occi::Core::Actions.new(self.actions),
                                       location = '/compute/'

      require 'occi/infrastructure/resource_tpl'
      require 'occi/infrastructure/os_tpl'
      self.mixins = Occi::Core::Mixins.new << Occi::Infrastructure::ResourceTpl.mixin << Occi::Infrastructure::OsTpl.mixin

      def architecture
        @attributes.occi_.compute_.architecture
      end

      def architecture=(architecture)
        @attributes.occi!.compute!.architecture = architecture
      end

      def cores
        @attributes.occi_.compute_.cores
      end

      def cores=(cores)
        @attributes.occi!.compute!.cores = cores
      end

      def hostname
        @attributes.occi_.compute_.hostname
      end

      def hostname=(hostname)
        @attributes.occi!.compute!.hostname = hostname
      end

      def speed
        @attributes.occi_.compute_.speed
      end

      def speed=(speed)
        @attributes.occi!.compute!.speed = speed
      end

      def memory
        @attributes.occi_.compute_.memory
      end

      def memory=(memory)
        @attributes.occi!.compute!.memory = memory
      end

      def state
        @attributes.occi_.compute_.state
      end

      def state=(state)
        @attributes.occi!.compute!.state = state
      end

      def storagelink(target, mixins=[], attributes=Occi::Core::Attributes.new, kind=Occi::Infrastructure::Storagelink.kind)
        link(target, kind, mixins, attributes, rel=Occi::Infrastructure::Storage.type_identifier)
      end

      def networkinterface(target, mixins=[], attributes=Occi::Core::Attributes.new, kind=Occi::Infrastructure::Networkinterface.kind)
        link(target, kind, mixins, attributes, rel=Occi::Infrastructure::Network.type_identifier)
      end

      def storagelinks
        @links.select { |link| link.kind == Occi::Infrastructure::Storagelink.kind }
      end

      def networkinterfaces
        @links.select { |link| link.kind == Occi::Infrastructure::Networkinterface.kind }
      end

    end
  end
end
