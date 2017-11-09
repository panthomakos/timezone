# frozen_string_literal: true

require 'timezone/lookup/geonames'
require 'timezone/lookup/google'
require 'timezone/lookup/test'
require 'timezone/net_http_client'

module Timezone
  # Configure timezone lookups.
  module Lookup
    class << self
      MISSING_LOOKUP = 'No lookup configured'.freeze
      private_constant :MISSING_LOOKUP

      # Returns the lookup object
      #
      # @return [#lookup] the lookup object
      # @raise [Timezone::Error::InvalidConfig] if the lookup has not
      #   been configured
      def lookup
        @lookup || raise(::Timezone::Error::InvalidConfig, MISSING_LOOKUP)
      end

      # Configure a lookup object
      #
      # @param lookup [:google, :geonames, :test] use a built-in lookup
      # @param lookup [Class] a custom lookup class
      # @yieldparam [OpenStruct] an object on which to set configuration
      #   options
      #
      # @return [#lookup] the lookup object
      def config(lookup)
        options = OptionSetter.new(lookup)
        yield(options.config) if block_given?
        @lookup = options.make_lookup
      end
    end

    # Responsible for collecting options in the DSL and creating
    # lookup objects using those options.
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

      def make_lookup
        config.request_handler ||= ::Timezone::NetHTTPClient
        @lookup.new(config)
      end
    end

    private_constant :OptionSetter
  end
end
