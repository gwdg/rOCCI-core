module Occi
  module Core
    # Contains all parsing-related classes and modules. This
    # module houses functionality transforming various internal
    # over-the-wire renderings into Ruby instances. In most
    # cases, it is intended to be called explicitly.
    #
    # This is also the place where additional parsing engines
    # should be added. Please, refer to internal documentation
    # for details on how to add a new parsing engine.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Parsers; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'parsers', '*.rb')].each { |file| require file.gsub('.rb', '') }
