module Occi
  module Helpers
    module Comparators
      module Collection

        REQUIRED_ACCESSORS = [:kinds, :mixins, :actions, :resources, :links, :action].freeze

        def ==(obj)
          return false unless obj && has_accessors?(obj)
          contents_matches?(obj)
        end

        def eql?(obj)
          self == obj
        end

        def hash
          REQUIRED_ACCESSORS.collect { |accessor| self.send(accessor) }.hash
        end

        def has_accessors?(obj)
          result = true
          REQUIRED_ACCESSORS.each { |accessor| result = result && obj.respond_to?(accessor) }

          result
        end
        private :has_accessors?

        def contents_matches?(obj)
          result = true
          REQUIRED_ACCESSORS.each { |accessor| result = result && (self.send(accessor) == obj.send(accessor)) }

          result
        end
        private :contents_matches?

      end
    end
  end
end