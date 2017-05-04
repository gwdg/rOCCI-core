module Occi
  module Core
    module Helpers
      # Introduces additional error handling functions to the receiver
      # class and its instnaces.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module ErrorHandler
        # Wraps potential exceptions raised in the given block in the specified
        # exception class. Internal exception can be later exposed via `Exception#cause`.
        #
        # @param klass [Class] raise error of this class if necessary
        def handle(klass)
          raise 'You have to provide a block' unless block_given?
          begin
            yield # do whatever you need to do
          rescue => ex
            raise klass, ex.message
          end
        end

        # :nodoc:
        def self.included(klass)
          klass.extend self
        end
      end
    end
  end
end
