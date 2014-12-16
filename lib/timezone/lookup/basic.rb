module Timezone
  module Lookup
    class Basic
      attr_reader :config

      def initialize(config)
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
