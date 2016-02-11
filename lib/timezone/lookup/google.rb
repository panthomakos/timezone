require 'timezone/lookup/basic'
require 'timezone/error'
require 'json'
require 'uri'
require 'base64'
require 'openssl'
require 'cgi'

module Timezone
  module Lookup
    class Google < ::Timezone::Lookup::Basic
      def initialize(config)
        if config.api_key.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing api key'.freeze)
        end

        config.protocol ||= 'https'.freeze
        config.url ||= 'maps.googleapis.com'.freeze

        super
      end

      def lookup(lat, long)
        response = client.get(url(lat, long))

        if response.code == '403'.freeze
          raise(Timezone::Error::Google, '403 Forbidden'.freeze)
        end

        return unless response.code =~ /^2\d\d$/
        data = JSON.parse(response.body)

        if data['status'.freeze] != 'OK'.freeze
          raise(Timezone::Error::Google, data['errorMessage'])
        end

        data['timeZoneId'.freeze]
      rescue => e
        raise(Timezone::Error::Google, e.message)
      end

      private

      def use_google_enterprise?
        !!config.client_id
      end

      def authorize(url)
        if use_google_enterprise?
          url += "&client=#{CGI.escape(config.client_id)}"

          sha1 = OpenSSL::Digest.new('sha1')
          binary_key = Base64.decode64(config.api_key.tr('-_','+/'))
          binary_signature = OpenSSL::HMAC.digest(sha1, binary_key, url)
          signature = Base64.encode64(binary_signature).tr('+/','-_').strip

          url + "&signature=#{signature}"
        else
          url + "&key=#{config.api_key}"
        end
      end

      def url(lat, long)
        query = URI.encode_www_form(
          'location' => "#{lat},#{long}",
          'timestamp' => Time.now.to_i)

        authorize("/maps/api/timezone/json?#{query}")
      end
    end
  end
end
