module Occi
  module Infrastructure
    module Actions
      # Class without internal logic intented to help with creating a specific
      # action.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class ComputeStop < Occi::Core::Action
        SCHEMA = 'http://schemas.ogf.org/occi/infrastructure/compute/action#'.freeze
        TERM   = 'stop'.freeze
        TITLE  = 'Action stopping compute instance'.freeze

        def initialize
          super(term: TERM, schema: SCHEMA, title: TITLE)
        end
      end
    end
  end
end
