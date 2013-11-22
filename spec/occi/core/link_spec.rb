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
                                           :default => 'defaultvalue', :mutable => true, :required => true }
          defs }
        let(:kind){ Occi::Core::Kind.new 'http://schemas.ogf.org/occi/core#', 'testkind', 'Test Kind', defs }
        let(:model){ model = Occi::Model.new
          model.register(kind)
          model }

        let(:link){ link = Occi::Core::Link.new(kind, [], defs)
          link.model = model
          link }

        it 'sets default' do
          link.check
          expect(link.attributes['stringtype']).to eql 'defaultvalue'
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
