module Occi
  module Infrastructure
    # Contains various INFRA-specific `Occi::Core::Action` sub-classes with pre-set
    # attributes (OCCI attributes and Ruby attributes). For details, see documentation
    # for the particular class.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Actions; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'actions', '*.rb')].each { |file| require file.gsub('.rb', '') }
