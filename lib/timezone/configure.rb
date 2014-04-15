require 'timezone/net_http_client'

module Timezone
  # Configuration class for the Timezone gem.
  #
  # You'll want to sign up for a geonames username at
  # {http://www.geonames.org/login Geonames}. Use the username to
  # configure your application for latitude and longitude based
  # timezone searches.
  #
  # If you aren't going to initialize timezone objects based on lat,lng
  # then this configuration is not necessary.
  #
  # @example
  #     Timezone::Configure.begin do |c|
  #       c.url = 'api.geonames.org'
  #       c.username = 'foo-bar'
  #     end
  #
  class Configure
    # The Geonames API URL
    #
    # @return [Sting]
    #   the Geonames API URL ('api.geonames.org')
    def self.url
      @@url ||= 'api.geonames.org'
    end

    # The Geonames API URL
    #
    # @param [Sting] url
    #   the Geonames API URL
    def self.url=(url)
      @@url = url
    end

    # The Geonames API HTTP protocol
    #
    # @param [String] protocol
    #   the Geonames API HTTP procotol
    def self.protocol=(protocol)
      @@protocol = protocol
    end

    # The Geonames API HTTP protocol
    #
    # @return [Sting]
    #   the Geonames API URL ('api.geonames.org')
    def self.protocol
      @protocol ||= 'http'
    end

    # The HTTP client that handles requests to geonames
    #
    # @return [Object]
    #   the HTTP client ({Timezone::NetHTTPClient Timezone::NetHTTPClient})
    def self.http_client
      @@http_client ||= Timezone::NetHTTPClient
    end

    # The HTTP client that handles requests to geonames
    #
    # @param [Object] client
    #   the HTTP client that handles requests to geonames
    #
    def self.http_client=(client)
      @@http_client = client
    end

    def self.username
      @@username
    end

    def self.username= username
      @@username = username
    end

    def self.begin
      yield self
    end

    def self.replace(what, with = Hash.new)
      replacements # instantiate @@replacements
      @@replacements[what] = with[:with]
    end

    def self.replacements
      @@replacements ||= {}
    end

    def self.default_for_list
      @@default_list ||= nil
    end

    def self.default_for_list=(*list)
      @@default_list = list.flatten!
    end

    def self.order_list_by
      @@order_by ||= :utc_offset
    end

    def self.order_list_by=(order)
      @@order_by = order
    end
  end
end
