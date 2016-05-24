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

        return unless response.body

        data = JSON.parse(response.body)

        timezone_id = get_timezone_id(data)
        return timezone_id if timezone_id

        return unless data['status']

        raise(Timezone::Error::GeoNames, data['status']['message'])
      rescue => e
        raise(Timezone::Error::GeoNames, e.message)
      end

      private

      def get_timezone_id(data)
        return data['timezoneId'] if data['timezoneId']

        if config.offset_etc_zones && data['gmtOffset']
          return unless data['gmtOffset'].is_a? Numeric
          return 'Etc/UTC' if data['gmtOffset'] == 0
          "Etc/GMT#{format('%+d', -data['gmtOffset'])}"
        end
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
