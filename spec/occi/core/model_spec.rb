module Occi
  module Core
    describe Model do
      subject(:mdl) { model }
      let(:model) { Model.new }

      it 'has logger' do
        expect(mdl).to respond_to(:logger)
        expect(mdl.class).to respond_to(:logger)
      end

      it 'is renderable' do
        expect(mdl).to be_kind_of(Helpers::Renderable)
        expect(mdl).to respond_to(:render)
      end

      describe '#valid!'
      describe '#valid?'
    end
  end
end
