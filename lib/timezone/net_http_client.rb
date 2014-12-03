require 'uri'
require 'net/http'

module Timezone
  # A basic HTTP Client that handles requests to Geonames and Google. You
  # can create your own version of this class if you want to use a proxy
  # or a different http library such as faraday but be aware that the 
  # Google timezone API uses https protocol.
  #
  # @example
  #     Timezone::Configure.begin do |c|
  #       c.http_client = Timezone::NetHTTPClient
  #     end
  class NetHTTPClient
    def initialize(protocol, host)
      uri = URI.parse("#{protocol}://#{host}")
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = (protocol == 'https')
    end

    def get(url)
      @http.request(Net::HTTP::Get.new(url))
    end
  end
end
