module Occi
  module Infrastructure
    # Extended loader for static categories defined in the OCCI Infra Standard
    # published by OGF's OCCI WG. This warehouse is meant to be used as a
    # quick bootstrap tools for `Occi::Core::Model` instances. Instances passed
    # to this warehouse MUST be already boostrapped by `Occi::Core::Warehouse`.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Warehouse < Occi::Core::Warehouse
      class << self
        protected

        # :nodoc:
        def whereami
          File.expand_path(File.dirname(__FILE__))
        end
      end
    end
  end
end
