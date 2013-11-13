module Occi
  describe Core do

    context ".kinds" do
      it 'initializes kinds' do
        kinds = Occi::Core.kinds
        expected = Occi::Core::Kinds.new << Occi::Core::Entity.kind << Occi::Core::Link.kind << Occi::Core::Resource.kind
        expect(kinds).to eql expected
      end
    end
  end
end
