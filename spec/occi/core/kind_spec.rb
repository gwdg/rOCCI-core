module Occi
  module Core
    describe Kind do

      describe '#get_class' do

        it 'gets OCCI Resource class by term and scheme' do
          scheme = 'http://schemas.ogf.org/occi/core'
          term = 'resource'
          klass = Occi::Core::Kind.get_class scheme, term
          klass.should be Occi::Core::Resource
          klass.superclass.should be Occi::Core::Entity
        end

        it 'gets non predefined OCCI class by term, scheme and related class' do
          scheme = 'http://example.com/occi'
          term = 'test'
          related = ['http://schemas.ogf.org/occi/core#resource']
          klass = Occi::Core::Kind.get_class scheme, term, related
          klass.should be Com::Example::Occi::Test
          klass.superclass.should be Occi::Core::Resource
        end

        it 'does not get OCCI class by term and scheme if it relates to existing class not derived from OCCI Entity' do
          scheme = 'http://hashie/'
          term = 'mash'
          related = ['http://schemas.ogf.org/occi/core#resource']
          expect { Occi::Core::Kind.get_class scheme, term, related }.to raise_error
        end

      end

      describe '#related_to?' do

        it 'checks if the kind is related to another kind' do
          kind = Occi::Core::Resource.kind
          kind.related_to?(Occi::Core::Entity.kind).should be true
        end

      end

      describe '#as_json' do

        it 'renders JSON correctly from freshly initialized object' do
          kind = Occi::Core::Resource.kind
	  expected = '{"parent":"http://schemas.ogf.org/occi/core#entity","related":["http://schemas.ogf.org/occi/core#entity"],"location":"/new_location/","scheme":"http://schemas.ogf.org/occi/core#","term":"resource","title":"resource","attributes":{"occi":{"core":{"summary":{"type":"string","mutable":true,"pattern":".*"},"_summary":{"type":"string","mutable":true,"pattern":".*"}}}}}'
	  hash=Hashie::Mash.new(JSON.parse(expected))
	  expect(kind.as_json).to be_json_eql(hash)
        end

      end

    end
  end
end
