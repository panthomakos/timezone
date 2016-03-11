require 'uri'
require 'net/http'

module Timezone
  # @!visibility private
  # A basic HTTP Client that handles requests to Geonames and Google.
  #
  # You can create your own version of this class if you want to use
  # a proxy or a different http library such as faraday.
  #
  # @example
  #     Timezone::Lookup.config(:google) do |c|
  #       c.api_key = 'foo'
  #       c.request_handler = Timezone::NetHTTPClient
  #     end
  #
  class NetHTTPClient
    def initialize(config)
      uri = URI.parse("#{config.protocol}://#{config.url}")
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.open_timeout = config.open_timeout || 5
      @http.read_timeout = config.read_timeout || 5
      @http.use_ssl = (config.protocol == 'https'.freeze)
    end

    def get(url)
      @http.request(Net::HTTP::Get.new(url))
    end
  end
end
