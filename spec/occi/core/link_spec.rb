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
        let(:kind){ Occi::Core::Kind.new 'http://schemas.ogf.org/occi/core#', 'testkind', 'Test Kind', defs }
        let(:model){ model = Occi::Model.new
          model.register(kind)
          model }

        it 'sets default for required attribute' do
          lnk = Occi::Core::Link.new(kind, [], defs)
          lnk.model = model
          lnk.check
          expect(lnk.attributes['stringtype']).to eql 'defaultforlink'
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
