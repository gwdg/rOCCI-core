module Occi
  module Core
    module Helpers
      # Introduces location-based capabilities to every receiver
      # class. Provides methods to access set location value
      # and generate default locations if necessary.
      #
      # @author Boris Parak <parak@cesnet.cz>
      module Locatable
        # Returns the location of this instance. Set location
        # is preferred over the generated one. If no location is known
        # one is generated from available information specific to
        # this instance.
        #
        # @example
        #   obj.location # => #<URI::Generic /my_location/>
        #
        # @return [URI] instance location
        def location
          @location || generate_location
        end

        # Generates default location based on the already configured
        # instance attribute(s). Fails if required attributes are not
        # present.
        #
        # @example
        #   obj.generate_location # => #<URI::Generic /my_location/>
        #
        # @return [URI] generated location
        # @abstract This method MUST be implemented in every 'locatable' class
        def generate_location
          raise "Cannot generate default location for #{self.class}, I don't know how"
        end

        protected :generate_location
      end
    end
  end
end
