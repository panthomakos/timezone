require 'timezone/lookup/basic'
require 'timezone/error'

module Timezone
  module Lookup
    # @!visibility private
    class Test < ::Timezone::Lookup::Basic
      def initialize(config)
        @stubs = {}
        # Regular config w/ protocol and URL checks does not apply
        # for stubs.
      end

      def stub(lat, long, timezone)
        @stubs[key(lat, long)] = timezone
      end

      def lookup(lat, long)
        @stubs.fetch(key(lat, long)) do
          raise ::Timezone::Error::Test, 'missing stub'
        end
      end

      private

      def key(lat, long)
        "#{lat},#{long}"
      end
    end
  end
end
