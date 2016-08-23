module Occi
  module Core
    describe Resource do
      subject(:res) { resource }

      let(:kind) { instance_double('Occi::Core::Kind') }

      let(:resource) { Resource.new(kind: kind, title: 'My Resource') }
    end
  end
end
