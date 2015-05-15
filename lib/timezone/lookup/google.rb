require 'timezone/lookup/basic'
require 'timezone/error'
require 'json'
require 'uri'

module Timezone
  module Lookup
    class Google < ::Timezone::Lookup::Basic
      def initialize(config)
        if config.google_api_key.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing api key')
        end
        super
      end

      def lookup(lat,lng)
        response = client.get(url(lat,lng))

        return unless response.code =~ /^2\d\d$/
        data = JSON.parse(response.body)

        if data['status'] != 'OK'
          raise(Timezone::Error::Google, data['errorMessage'])
        end

        data['timeZoneId']
      rescue => e
        raise(Timezone::Error::Google, e.message)
      end

      private

      def url(lat,lng)
          query = URI.encode_www_form(
            'location' => "#{lat},#{lng}",
            'timestamp' => Time.now.to_i,
            'key' => config.google_api_key)

          "/maps/api/timezone/json?#{query}"
      end
    end
  end
end
