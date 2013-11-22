module Occi
  module Core
    describe Link do
      # XXX This is a poor man's spec file, by no means exhaustive
      # XXX So far it is only used to cover code otherwise not
      # XXX covered by calls from other specs

      context '#check' do
        let(:defs){
          defs = Occi::Core::Attributes.new
          defs['occi.core.id'] = { :type=> 'string', :required => true }
          defs['stringtype'] =   { :type => 'string', :pattern => '[adefltuv]+',
                                           :default => 'defaultforlink', :mutable => true, :required => true }
          defs }

        it 'sets default for required attribute' do
          link = Occi::Core::Link.new
          link.kind.attributes.merge!(defs)
          model = Occi::Model.new
          model.register(link.kind)
          link.model = model

          link.check
          expect(link.attributes['stringtype']).to eql 'defaultforlink'
        end

        it 'raises error if no relationship is set' do
          norel = Occi::Core::Link.new
          norel.instance_eval { @rel=nil }
          expect{ norel.check }.to raise_exception ArgumentError
        end
      end 
    end
  end
end
