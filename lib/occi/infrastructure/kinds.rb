module Occi
  module Infrastructure
    # Contains various INFRA-specific `Occi::Core::Kind` sub-classes with pre-set
    # attributes (OCCI attributes and Ruby attributes). For details, see documentation
    # for the particular class.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Kinds; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'kinds', '*.rb')].each { |file| require file.gsub('.rb', '') }
