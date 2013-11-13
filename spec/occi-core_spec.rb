describe Occi do
  include Occi

  context ".kinds" do
    it 'initializes kinds' do
      kind = kinds
      expect(kind).to eql []
    end
  end

  context ".mixins" do
    it 'initializes mixins' do
      mixin = mixins
      expect(mixin).to eql []
    end
  end

  context ".actions" do
    it 'initializes actions' do
      action = actions
      expect(actions).to eql []
    end
  end

  context ".categories" do
    it 'returns lists of categories' do
      cat = categories
      expect(cat).to eql []
    end
  end
end
