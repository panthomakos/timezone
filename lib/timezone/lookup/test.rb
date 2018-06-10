# frozen_string_literal: true

require 'timezone/lookup/basic'
require 'timezone/error'

module Timezone
  module Lookup
    # @!visibility private
    class Test < ::Timezone::Lookup::Basic
      def initialize(_config)
        @stubs = {}
        @default_stub = nil
      end

      def stub(lat, long, timezone)
        @stubs[key(lat, long)] = timezone
      end

      def unstub(lat, long)
        @stubs.delete(key(lat, long))
      end

      def default(timezone)
        @default_stub = timezone
      end

      def lookup(lat, long)
        @stubs.fetch(key(lat, long)) do
          @default_stub || raise(::Timezone::Error::Test, 'missing stub')
        end
      end

      private

      def key(lat, long)
        "#{lat},#{long}"
      end
    end
  end
end
