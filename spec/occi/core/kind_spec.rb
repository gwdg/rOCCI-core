module Occi
  module Core
    describe Kind do

      describe '#get_class' do

        context 'OCCI Resource class' do
          let(:scheme){ 'http://schemas.ogf.org/occi/core' }
          let(:term){ 'resource' }
          let(:klass){ Occi::Core::Kind.get_class scheme, term }

          it 'gets OCCI Resource class by term term and scheme' do
            expect(klass).to be Occi::Core::Resource
          end
          it 'also gets the superclass' do
            expect(klass.superclass).to be Occi::Core::Entity
            #TODO: Possibly move this test to resource_spec?
          end
        end

        context 'non-predefined OCCI class' do
          let(:scheme){ 'http://example.com/occi' }
          let(:term){ 'test' }
          let(:related){ ['http://schemas.ogf.org/occi/core#resource'] }
          let(:klass){ Occi::Core::Kind.get_class scheme, term, related }

          it 'gets non predefined OCCI class by term, scheme and related class' do
            expect(klass).to be Com::Example::Occi::Test
          end
          it 'also gets the superclass' do
            expect(klass.superclass).to be Occi::Core::Resource
            #TODO: Possibly move this test to resource_spec?
          end
        end

        it 'does not get OCCI class by term and scheme if it relates to existing class not derived from OCCI Entity' do
          scheme = 'http://hashie/'
          term = 'mash'
          related = ['http://schemas.ogf.org/occi/core#resource']
          expect { Occi::Core::Kind.get_class scheme, term, related }.to raise_error
        end

        context 'in case of improper input' do

          it 'handles parent overriden with nil' do
            expect(Occi::Core::Kind.get_class 'http://schemas.ogf.org/occi/core', 'resource', nil).to eq Occi::Core::Resource
          end
          
          it 'copes with invalid characters in scheme' do
            expect{Occi::Core::Kind.get_class 'http://schemas ogf.org/occi/core', 'resource'}.to raise_error(URI::InvalidURIError)
          end
          it 'copes with non-URI-like structure of the scheme' do
            expect{Occi::Core::Kind.get_class 'doesnotexist', 'resource'}.to raise_error(StandardError)
          end

          context 'handling invalid characters in term' do
            after { Occi::Settings.reload! }
            it 'copes with compatibility on' do
              Occi::Settings['compatibility'] = true
              expect(Occi::Core::Kind.get_class 'http://schemas.ogf.org/occi/core', '# #resource$').to eq Occi::Core::Resource
            end
            
            it 'copes with compatibility off' do
              Occi::Settings['compatibility'] = false
              expect{Occi::Core::Kind.get_class 'http://schemas.ogf.org/occi/core', '# #resource$'}.to raise_error(ArgumentError)
            end
          end
          
          it 'handles nil scheme' do
            expect{Occi::Core::Kind.get_class nil, 'resource'}.to raise_error(ArgumentError)
          end

          it 'handles nil resource' do
            expect{Occi::Core::Kind.get_class 'http://schemas.ogf.org/occi/core', nil}.to raise_error(ArgumentError)
          end

          it 'copes with invalid parent' do
            expect{Occi::Core::Kind.get_class 'http://example.com/occi', 'test', 'http://s  chemas.ogf.org/occi/core#resource'}.to raise_error(URI::InvalidURIError)
          end

          it 'copes with parent missing term' do
            expect{Occi::Core::Kind.get_class 'http://example.com/occi', 'test', 'http://s  chemas.ogf.org/occi/core'}.to raise_error(ArgumentError)
          end

        end

      end

      describe '#location' do
        let(:kind) { Occi::Core::Kind.new }

        it 'gets normalized to a relative path' do
          kind.location = 'http://example.org/kind/'
          expect(kind.location).to eq '/kind/'
        end

        it 'can be set to nil' do
          kind.location = nil
          expect(kind.location).to be_nil
        end

        it 'raises an error when location does not start and end with a slash' do
          expect { kind.location = '/no_slash' }.to raise_error
          expect { kind.location = 'no_slash/' }.to raise_error
        end

        it 'raises an error when location contains spaces' do
          expect { kind.location = '/sla shes/' }.to raise_error
        end

        it 'can be set to an empty string' do
          expect { kind.location = '' }.not_to raise_error
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
          expected = '{"location":"/kind/","term":"kind","scheme":"http://schemas.ogf.org/occi/core#","attributes":{}}'
          hash=Hashie::Mash.new(JSON.parse(expected))
          expect(kind.as_json).to eql(hash)
        end

        it 'renders JSON correctly with optional attributes' do
          kind.title = "test title"
          expected = '{"location":"/kind/","term":"kind","scheme":"http://schemas.ogf.org/occi/core#","title":"test title","attributes":{}}'
          hash=Hashie::Mash.new(JSON.parse(expected))
          expect(kind.as_json).to eql(hash)
        end

        it 'renders JSON correctly with special characters' do
          kind.title = "Some special characters @#\$%"
          expected = '{"location":"/kind/","term":"kind","scheme":"http://schemas.ogf.org/occi/core#","title":"Some special characters @#\$%","attributes":{}}'
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
