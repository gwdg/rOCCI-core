module Occi
  module Core
    # Implments handling helpers for OCCI locations. These are especially useful for rendering
    # and butter-passing purposes.
    #
    # @attr uris [Set] collection of URIs representing locations
    #
    # @author Boris Parak <parak@cesnet.cz>
    class Locations
      include Yell::Loggable
      include Helpers::Renderable
      include Helpers::ArgumentValidator
      include Enumerable

      # Methods to be redirected to `uris`
      ENUM_METHODS = %i[each << add remove map! empty? include?].freeze
      delegate(*ENUM_METHODS, to: :uris)

      attr_accessor :uris

      # Constructs an instance with given URIs. If `uris` are omitted, an empty
      # set will be automatically provided.
      #
      # @param args [Hash] arguments with Location information
      # @option args [Set] :uris collection of URIs representing locations
      def initialize(args = {})
        pre_initialize(args)
        default_args! args

        @uris = args.fetch(:uris)

        post_initialize(args)
      end

      # Applies given `host` to all locations contained in the collection.
      #
      # @param host [String] hostname for locations
      def host=(host)
        each { |uri| uri.host = host }
      end

      # Applies given `port` to all locations contained in the collection.
      #
      # @param port [String] port number
      def port=(port)
        each { |uri| uri.port = port }
      end

      # Applies given `scheme` to all locations contained in the collection.
      #
      # @param scheme [String] URI scheme
      def scheme=(scheme)
        each { |uri| uri.scheme = scheme }
      end

      # Validates all locations contained in the collection. Validation
      # errors are only logged.
      #
      # @return [TrueClass] if locations are valid
      # @return [FalseClass] if locations are invalid
      def valid?
        valid!
        true
      rescue => ex
        logger.warn "Location invalid: #{ex.message}"
        false
      end

      # Validates all locations in the collections and raises an error
      # if there is an invalid location. During this process, all locations
      # will be converted to `URI` instances.
      #
      # @raise [Occi::Core::Errors::LocationValidationError] if some location is invalid
      def valid!
        map! { |uri| return_or_convert uri }
      rescue => ex
        raise Occi::Core::Errors::LocationValidationError, ex.message
      end
      alias convert! valid!

      protected

      # :nodoc:
      def sufficient_args!(args)
        return if args[:uris]
        raise Occi::Core::Errors::MandatoryArgumentError, "'uris' is a mandatory argument for #{self.class}"
      end

      # :nodoc:
      def defaults
        { uris: Set.new }
      end

      # :nodoc:
      def pre_initialize(args); end

      # :nodoc:
      def post_initialize(args); end

      private

      # :nodoc:
      def return_or_convert(uri)
        return uri if uri.is_a?(URI)
        URI.parse uri
      end
    end
  end
end
