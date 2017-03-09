module Occi
  module Infrastructure
    # Contains various INFRA-specific `Occi::Core::Mixin` sub-classes with pre-set
    # attributes (OCCI attributes and Ruby attributes). For details, see documentation
    # for the particular class.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Mixins; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'mixins', '*.rb')].each { |file| require file.gsub('.rb', '') }
