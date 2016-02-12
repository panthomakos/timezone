require 'timezone/error'

module Timezone
  module Lookup
    # @abstract Subclass and override {#lookup} to implement
    #   a custom Lookup class.
    class Basic
      attr_reader :config

      # @param config [#protocol, #url, @http_client] a configuration
      #   object
      def initialize(config)
        if config.protocol.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing protocol')
        end

        if config.url.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing url')
        end

        @config = config
      end

      # Returns an instance of the http client.
      #
      # @return [#get] an instance of an http client
      def client
        @client ||= config.http_client.new(config.protocol, config.url)
      end

      # Returns a timezone name for a given lat, long pair.
      #
      # @param lat [Double] latitude coordinate
      # @param long [Double] longitude coordinate
      # @return [String] the timezone name
      # @return [nil] if the lat, long pair does not resolve to an
      #   actual timezone
      # @raise [Timezone::Error::Base] if an error occurred while
      #   while performing the lookup
      def lookup(lat, long)
        raise NoMethodError, 'lookup is not implemented'
      end
    end
  end
end
