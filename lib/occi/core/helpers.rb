module Occi
  module Core
    # Contains various helper modules and classes shared with
    # the rest of the code. For details, see documentation
    # for the particular helper.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Helpers; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'helpers', '*.rb')].each { |file| require file.gsub('.rb', '') }
