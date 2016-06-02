module Occi
  module Core
    # Contains all rendering-related classes and modules. This
    # module houses functionality transforming various internal
    # instances to standardized over-the-wire renderings. In most
    # cases, it is not intended to be called explicitly. Its
    # instrumentation will be used automatically by selected
    # instances when calling `render` or `to_<format>`.
    #
    # This is also the place where additional rendering formats
    # should be added. Please, refer to internal documentation
    # for details on how to add a new rendering format.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Renderers; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'renderers', '*.rb')].each { |file| require file.gsub('.rb', '') }
