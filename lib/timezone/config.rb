require 'timezone/lookup'
require 'timezone/net_http_client'

module Timezone
  # TODO: Documentation
  class Config
    class << self
      MISSING_LOOKUP = 'No lookup configured'.freeze

      # TODO: Documentation
      def lookup
        @lookup || raise(::Timezone::Error::InvalidConfig, MISSING_LOOKUP)
      end

      # TODO: Documentation
      def config(lookup)
        options = OptionSetter.new(lookup)
        yield(options.config) if block_given?
        @lookup = options.lookup
      end

      class OptionSetter
        LOOKUPS = {
          geonames: ::Timezone::Lookup::Geonames,
          google: ::Timezone::Lookup::Google,
          test: ::Timezone::Lookup::Test
        }.freeze

        INVALID_LOOKUP = 'Invalid lookup specified'.freeze

        attr_reader :config

        def initialize(lookup)
          if lookup.is_a?(Symbol)
            lookup = LOOKUPS.fetch(lookup) do
              raise ::Timezone::Error::InvalidConfig, INVALID_LOOKUP
            end
          end

          @lookup = lookup

          @config = OpenStruct.new
        end

        def lookup
          config.http_client ||= ::Timezone::NetHTTPClient
          @lookup.new(config)
        end
      end

      private_constant :OptionSetter
    end
  end
end
