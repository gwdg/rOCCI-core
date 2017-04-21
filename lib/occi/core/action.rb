module Occi
  module Core
    # Class without internal logic semantically separating `Category` and
    # `Action` instances for rendering purposes.
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Action < Category
      class << self
        # :nodoc:
        def allowed_yaml_classes
          # TODO: get rid of this with referenced (name-only) attributes in Action YAMLs
          [String, Regexp, URI, IPAddr, Integer, Float].freeze
        end
        private :allowed_yaml_classes
      end
    end
  end
end
