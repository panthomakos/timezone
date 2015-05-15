require 'timezone/error'

module Timezone
  module Lookup
    class Basic
      attr_reader :config

      def initialize(config)
        if config.protocol.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing protocol')
        end

        if config.url.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing url')
        end

        @config = config
      end

      def client
        @client ||= config.http_client.new(config.protocol, config.url)
      end

      def lookup(lat, lng)
        raise NoMethodError, 'lookup is not implemented'
      end
    end
  end
end
