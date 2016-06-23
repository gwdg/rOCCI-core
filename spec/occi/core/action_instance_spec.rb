module Occi
  module Core
    describe ActionInstance do
      subject { action_instance }

      let(:action) { instance_double('Occi::Core::Action') }
      let(:attributes) { { 'method' => instance_double('Occi::Core::Attribute') } }
      let(:action_instance) { ActionInstance.new(action: action, attributes: attributes) }

      AI_ATTRS = [:action, :attributes].freeze

      AI_ATTRS.each do |attr|
        it "has #{attr} accessor" do
          is_expected.to have_attr_accessor attr.to_sym
        end
      end

      describe '#valid?' do
        it 'returns `true` when action and attributes valid'
        it 'returns `false` when action invalid'
        it 'returns `false` when action missing'
        it 'returns `false` when attribute(s) invalid'
        it 'returns `false` when attributes missing'
        it 'returns `false` when both action and attributes invalid'
        it 'returns `false` when both action and attributes missing'
      end

      describe '#valid!' do
        it 'does not raise error when action and attributes valid'
        it 'raises error when action invalid'
        it 'raises error when action missing'
        it 'raises error when attribute(s) invalid'
        it 'raises error when attributes missing'
        it 'raises error when both action and attributes invalid'
        it 'raises error when both action and attributes missing'
      end
    end
  end
end
