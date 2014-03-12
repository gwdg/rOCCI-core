module Occi
  module Core
    describe Links do

      context '.initialize' do
        it 'initializes an empty Links set' do
          links = Occi::Core::Links.new
          expect(links).to eql []
        end

        context 'with multiple members' do
          let(:link1){ Occi::Core::Link.new }
          let(:link2){ Occi::Core::Link.new }
          let(:links){ Occi::Core::Links.new [link1,link2] }
          let(:expected){ expected = []
            links.each { |ln| expected << ln.id }
            expected }

          it 'produces the right number of members' do
            expect(links.count).to eql 2
          end

          it 'has the first link' do
            expect(link1.id).to satisfy { |id| expected.include?(id) }
          end

          it 'has the second link' do
            expect(link2.id).to satisfy { |id| expected.include?(id) }
          end
        end

        context 'with strings' do
          it 'produces the right number of members, strings only' do
            links = Occi::Core::Links.new ["target1","target2"]
            expect(links.count).to eql 2
          end

          it 'populates Links with correctly initialized links' do
            links = Occi::Core::Links.new ["/link/9c3b83bd-2456-45e9-8ce5-91a7d5c7bb85"]

            expect(links.first.id).to eql "9c3b83bd-2456-45e9-8ce5-91a7d5c7bb85"
            expect(links.first.location).to eql "/link/9c3b83bd-2456-45e9-8ce5-91a7d5c7bb85"
          end

          it 'produces the right number of members, string/link combination' do
            link2 = Occi::Core::Link.new
            links = Occi::Core::Links.new ["target1",link2]
            expect(links.count).to eql 2
          end
        end


      end

      context '<<' do
        context 'into an empty set' do
          let(:link1){ Occi::Core::Link.new }
          let(:links){ links = Occi::Core::Links.new
            links << link1
            links }

          it 'produces the right number of members' do
            expect(links.count).to eql 1
          end

          it 'has the link' do
            expect(links.first.id).to eql link1.id
          end
        end

        context 'into a populated set' do
          let(:link1){ Occi::Core::Link.new }
          let(:link2){ Occi::Core::Link.new }
          let(:links){ links = Occi::Core::Links.new [link2]
            links << link1
            links }
          let(:expected){ expected = []
            links.each { |ln| expected << ln.id }
            expected }

          it 'produces the right number of members' do
            expect(links.count).to eql 2
          end

          it 'has the first link' do
            expect(link1.id).to satisfy { |id| expected.include?(id) }
          end

          it 'has the second link' do
            expect(link2.id).to satisfy { |id| expected.include?(id) }
          end
        end
      end

      context '.create' do
        context 'in an empty set' do
          let!(:links){ Occi::Core::Links.new }
          let!(:link1){ links.create }

          it 'produces the right number of members' do
            expect(links.count).to eql 1
          end

          it 'has the link' do
            expect(links.first.id).to eql link1.id
          end
        end

        context 'in a populated set' do
          let(:link2){ Occi::Core::Link.new }
          let!(:links){ Occi::Core::Links.new [link2] }
          let!(:link1){ links.create }
          let!(:expected){ expected = []
            links.each { |ln| expected << ln.id }
            expected }

          it 'produces the right number of members' do
            expect(links.count).to eql 2
          end

          it 'has the first link' do
            expect(link1.id).to satisfy { |id| expected.include?(id) }
          end

          it 'has the second link' do
            expect(link2.id).to satisfy { |id| expected.include?(id) }
          end
        end
      end
    end
  end
end
