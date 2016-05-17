module Occi
  module Core
    describe Category do

      it 'has term'
      it 'has schema'
      it 'has title'
      it 'has identifier'
      it 'has attribute definitions'

      it 'allows the change of term'
      it 'allows the change of schema'
      it 'allows the change of time'
      it 'does not allow the change of identifier'
      it 'allows the change of attribute definitions'

      it 'can validate term by returning boolean'
      it 'can validate schema by returning boolean'
      it 'can validate term by raising an error'
      it 'can validate schema by raising an error'

      it 'cannot be directly rendered'
      it 'can be checked for emptiness'
      it 'can be validated by returning boolean'
      it 'can be validated by raising an error'
      it 'can be compared with another instance'

      it 'is invalid without term'
      it 'is invalid without schema'
      it 'is invalid with empty term'
      it 'is invalid with empty schema'

    end
  end
end
