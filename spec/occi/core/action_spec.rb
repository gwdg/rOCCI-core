module Occi
  module Core
    describe Action do
      let(:example_term) { 'action' }
      let(:example_schema) { 'http://schemas.org/schema#' }
      let(:example_title) { 'Generic action' }
      let(:example_attributes) { instance_double('Hash') }

      it 'does not do anything special' do
        expect do
          Action.new(
            schema: example_schema, term: example_term, title: example_title, attributes: example_attributes
          )
        end.not_to raise_error
      end
    end
  end
end
