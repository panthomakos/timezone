require 'timezone/lookup/basic'
require 'timezone/error'

module Timezone
  module Lookup
    class Test < ::Timezone::Lookup::Basic
      def initialize(config)
        @stubs = {}
        # Regular config w/ protocol and URL checks does not apply for stubs.
      end

      def stub(lat, lng, timezone)
        @stubs[key(lat, lng)] = timezone
      end

      def lookup(lat, lng)
        @stubs.fetch(key(lat, lng)) do
          raise ::Timezone::Error::Test, 'missing stub'
        end
      end

      private

      def key(lat, lng)
        "#{lat},#{lng}"
      end
    end
  end
end
