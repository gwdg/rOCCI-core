module Occi
  module Infrastructure
    # Dummy sub-class of `Occi::Core::Link` meant to simplify handling
    # of known instances of the given sub-class. Does not contain any functionality.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class SecurityGroupLink < Occi::Core::Link; end
  end
end
