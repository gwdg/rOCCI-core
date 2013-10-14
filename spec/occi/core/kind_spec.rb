module Occi
  module Core
    describe Kind do

      describe '#get_class' do

        context 'gets OCCI Resource class' do
          let(:scheme){ 'http://schemas.ogf.org/occi/core' }
          let(:term){ 'resource' }
          let(:klass){ Occi::Core::Kind.get_class scheme, term }

          it 'by term' do
            expect(klass).to be Occi::Core::Resource
          end
          it 'by scheme' do
            expect(klass.superclass).to be Occi::Core::Entity
          end
        end

        context 'gets non predefined OCCI class by term, scheme and related class' do
          let(:scheme){ 'http://example.com/occi' }
          let(:term){ 'test' }
          let(:related){ ['http://schemas.ogf.org/occi/core#resource'] }
          let(:klass){ Occi::Core::Kind.get_class scheme, term, related }

          it 'by term' do
            expect(klass).to be Com::Example::Occi::Test
          end
          it 'by scheme' do
            expect(klass.superclass).to be Occi::Core::Resource
          end
        end

        it 'does not get OCCI class by term and scheme if it relates to existing class not derived from OCCI Entity' do
          scheme = 'http://hashie/'
          term = 'mash'
          related = ['http://schemas.ogf.org/occi/core#resource']
          expect { Occi::Core::Kind.get_class scheme, term, related }.to raise_error
        end

      end

      describe '#related_to?' do
        let(:base){ Occi::Core::Kind.new 'http://occi.test.case/core/kind', 'base' }
        let(:related){ Occi::Core::Kind.new 'http://occi.test.case/core/kind/base', 'related', 'title', Occi::Core::Attributes.new, base }
        let(:unrelated){ Occi::Core::Kind.new 'http://occi.test.case/core/kind', 'unrelated' }

        it 'recognizes existing relationship' do
          expect(related.related_to?(base)).to eq true
        end

        it 'does not give false positives on non-existent relationship' do
          expect(base.related_to?(unrelated)).to eq false
        end

        it 'recognizes transitive relationships' #do #TODO This test actually works, but fails because te feature is not yet implemented
#          grandchild = Occi::Core::Kind.new 'http://occi.test.case/core/kind/base', 'related', 'title', Occi::Core::Attributes.new, related
#          expect(grandchild.related_to?(base)).to eq true
#        end
      end

      describe '#as_json' do
        let(:kind){ Occi::Core::Kind.new }

        it 'renders JSON correctly from freshly initialized object' do
          expected = '{"location":"/kind/","term":"kind","scheme":"http://schemas.ogf.org/occi/core#"}'
          hash=Hashie::Mash.new(JSON.parse(expected))
          expect(kind.as_json).to eql(hash)
        end

        it 'renders JSON correctly with optional attributes' do
          kind.title = "test title"
          expected = '{"location":"/kind/","term":"kind","scheme":"http://schemas.ogf.org/occi/core#","title":"test title"}'
          hash=Hashie::Mash.new(JSON.parse(expected))
          expect(kind.as_json).to eql(hash)
        end


        it 'renders JSON correctly with special characters' do
          kind.title = "Some special characters @#\$%"
          expected = '{"location":"/kind/","term":"kind","scheme":"http://schemas.ogf.org/occi/core#","title":"Some special characters @#\$%"}'
          hash=Hashie::Mash.new(JSON.parse(expected))
          expect(kind.as_json).to eql(hash)
        end

      end

      describe '#to_string' do
        let(:kind){ Occi::Core::Kind.new }

        it 'produces a string correctly from freshly initialized object' do
          expected = ('scheme="http://schemas.ogf.org/occi/core#";class="kind";location="/kind/";kind').split(/;/)
          actual = kind.to_string.split(/;/)
          expect(actual).to match_array(expected)
        end

        it 'produces a string correctly with optional attributes' do
          kind.title = "test title"
          expected = ('scheme="http://schemas.ogf.org/occi/core#";class="kind";location="/kind/";kind;title="test title"').split(/;/)
          actual = kind.to_string.split(/;/)
          expect(actual).to match_array(expected)
        end

#        TODO: Optional attributes, special characters

      end

    end
  end
end
