module Occi
  module Core
    module Helpers
      # Introduces argument validation capabilities to every receiver
      # class. Should be used via the `include` or `extend` keywords.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module ArgumentValidator
        # :nodoc:
        def default_args!(args)
          args.merge!(defaults) { |_, oldval, _| oldval }
          sufficient_args!(args)
        end

        # :nodoc:
        def sufficient_args!(args); end

        # :nodoc:
        def defaults
          {}
        end

        private :defaults, :sufficient_args!, :default_args!
      end
    end
  end
end
