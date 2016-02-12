require 'timezone/lookup/basic'
require 'timezone/error'
require 'json'
require 'uri'

module Timezone
  module Lookup
    # @!visibility private
    class Geonames < ::Timezone::Lookup::Basic
      def initialize(config)
        if config.username.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing username'.freeze)
        end

        config.protocol ||= 'http'.freeze
        config.url ||= 'api.geonames.org'.freeze

        super
      end

      def lookup(lat, long)
        response = client.get(url(lat, long))

        return unless response.code =~ /^2\d\d$/

        data = JSON.parse(response.body)

        if data['status'] && data['status']['value'] == 18
          raise(Timezone::Error::GeoNames, 'api limit reached')
        end

        data['timezoneId']
      rescue => e
        raise(Timezone::Error::GeoNames, e.message)
      end

      private

      def url(lat, long)
        query = URI.encode_www_form(
          'lat' => lat,
          'lng' => long,
          'username' => config.username)
        "/timezoneJSON?#{query}"
      end
    end
  end
end
