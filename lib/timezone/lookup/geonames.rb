# frozen_string_literal: true

require 'timezone/lookup/basic'
require 'timezone/error'
require 'json'
require 'uri'

module Timezone
  module Lookup
    # @!visibility private
    class Geonames < ::Timezone::Lookup::Basic
      # Status code used by GeoNames to indicate that the lookup succeeded, but
      # there is no timezone information for the given <lat, lng>. This can
      # happen if the <lat, lng> resolves to a point in the middle of the ocean,
      # for example.
      NO_TIMEZONE_INFORMATION = 15

      def initialize(config)
        if config.username.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing username')
        end

        config.protocol ||= 'http'
        config.url ||= 'api.geonames.org'

        super
      end

      def lookup(lat, long)
        response = client.get(url(lat, long))

        return unless response.body

        data = JSON.parse(response.body)

        timezone_id = get_timezone_id(data)
        return timezone_id if timezone_id

        return unless data['status']

        return if NO_TIMEZONE_INFORMATION == data['status']['value']

        raise(Timezone::Error::GeoNames, data['status']['message'])
      rescue StandardError => e
        raise(Timezone::Error::GeoNames, e.message)
      end

      private

      def get_timezone_id(data)
        return data['timezoneId'] if data['timezoneId']

        return unless config.offset_etc_zones
        return unless data['gmtOffset']
        return unless data['gmtOffset'].is_a? Numeric

        return 'Etc/UTC' if data['gmtOffset'].zero?
        "Etc/GMT#{format('%+d', -data['gmtOffset'])}"
      end

      def url(lat, long)
        query = URI.encode_www_form(
          'lat' => lat,
          'lng' => long,
          'username' => config.username
        )
        "/timezoneJSON?#{query}"
      end
    end
  end
end
