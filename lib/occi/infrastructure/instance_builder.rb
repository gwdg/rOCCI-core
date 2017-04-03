module Occi
  module Infrastructure
    # See `Occi::Core::InstanceBuilder` for details.
    #
    # @attr model [Occi::Infrastructure::Model] model filled with known category definitions
    #
    # @author Boris Parak <parak@cesnet.cz>
    class InstanceBuilder < Occi::Core::InstanceBuilder
      # Looks up the appropriate candidate class for the given identifier. If no class
      # is found in static tables, the last known ancestor is returned. For Core, this
      # method ALWAYS returns the last known ancestor given as `last_ancestor`, for
      # compatibility reasons.
      #
      # @param identifier [String] identifier of the category
      # @return [Class] pre-defined class or given last ancestor
      def klass(_identifier, last_ancestor)
        # TODO: impl
        last_ancestor
      end

      class << self
        # :nodoc:
        def whereami
          File.expand_path(File.dirname(__FILE__))
        end
      end
    end
  end
end
