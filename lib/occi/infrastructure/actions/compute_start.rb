module Occi
  module Infrastructure
    module Actions
      # Class without internal logic intented to help with creating a specific
      # action.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class ComputeStart < Occi::Core::Action
        SCHEMA = 'http://schemas.ogf.org/occi/infrastructure/compute/action#'.freeze
        TERM   = 'start'.freeze
        TITLE  = 'Action starting compute instance'.freeze

        def initialize
          super(term: TERM, schema: SCHEMA, title: TITLE)
        end
      end
    end
  end
end
