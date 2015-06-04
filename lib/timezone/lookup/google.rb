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
        if config.google_api_key.nil?
          raise(::Timezone::Error::InvalidConfig, 'missing api key')
        end
        super
      end

      def lookup(lat,lng)
        response = client.get(url(lat,lng))

        if response.code == '403'
          raise(Timezone::Error::Google, '403 Forbidden')
        end

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

      def authorize(url)
        if config.use_google_enterprise?
          url += "&client=#{CGI.escape(config.google_client_id)}"

          sha1 = OpenSSL::Digest.new('sha1')
          binary_key = Base64.decode64(config.google_api_key.tr('-_','+/'))
          binary_signature = OpenSSL::HMAC.digest(sha1, binary_key, url)
          signature = Base64.encode64(binary_signature).tr('+/','-_').strip

          url + "&signature=#{signature}"
        else
          url + "&key=#{config.google_api_key}"
        end
      end

      def url(lat,lng)
        query = URI.encode_www_form(
          'location' => "#{lat},#{lng}",
          'timestamp' => Time.now.to_i)

        authorize("/maps/api/timezone/json?#{query}")
      end
    end
  end
end
