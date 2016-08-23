module Occi
  module Core
    describe Link do
      subject(:lnk) { link }

      let(:kind) { instance_double('Occi::Core::Kind') }

      let(:link) { Link.new(kind: kind, title: 'My Link') }
    end
  end
end
