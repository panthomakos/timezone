require 'timezone/net_http_client'
require 'timezone/lookup'

module Timezone
  # Configuration class for the Timezone gem.
  #
  # You'll want to sign up for a geonames username at
  # {http://www.geonames.org/login Geonames}. Use the username to
  # configure your application for latitude and longitude based
  # timezone searches.
  # Alternatively, you'll want to sign up for a Google api key at
  # {https://code.google.com/apis/console/ Google}. Use the api key to
  # configure your application for latitude and longitude based
  # timezone searches.
  #
  # If you aren't going to initialize timezone objects based on lat,lng
  # then this configuration is not necessary.
  #
  # @example
  #     Timezone::Configure.begin do |c|
  #       c.geonames_url = 'api.geonames.org'
  #       c.username = 'foo-bar'
  #       c.google_api_key = 'abc123'
  #     end
  #
  class Configure
    # The Google API key
    #
    # @return [String]
    #   the Google API key ('abc123')
    def self.google_api_key
      @google_api_key ||= nil
    end

    # Google API key
    #
    # @param [String] api_key
    #   the Google API key
    def self.google_api_key=(api_key)
      @google_api_key = api_key
    end

    # The Google Client ID (for enterprise)
    #
    # @return [String]
    #   the Google Client ('abc123')
    def self.google_client_id
      @google_client_id ||= nil
    end

    # Google Client ID (for enterprise)
    #
    # @param [String] client
    #   the Google Client
    def self.google_client_id=(client)
      @google_client_id = client
    end

    # Use Google API if key has been set
    #
    # @return [Boolean]
    def self.use_google?
      !!google_api_key
    end

    # Sign Google API request if client given (for enterprise)
    #
    # @return [Boolean]
    def self.use_google_enterprise?
      use_google? && !!google_client_id
    end

    def self.lookup
      use_google? ? google_lookup : geonames_lookup
    end

    def self.google_lookup
      @google_lookup ||= Timezone::Lookup::Google.new(self)
    end

    def self.geonames_lookup
      @geonames_lookup ||= Timezone::Lookup::Geonames.new(self)
    end

    # The Geonames API URL
    #
    # @return [String]
    #   the Geonames API URL ('api.geonames.org')
    def self.geonames_url
      @@geonames_url ||= 'api.geonames.org'
    end

    # The Geonames API URL
    #
    # @param [String] url
    #   the Geonames API URL
    def self.geonames_url=(url)
      @@geonames_url = url
    end

    class << self
      alias :url= :geonames_url=
    end

    # The Google API URL
    #
    # @return [String]
    #   the Google API URL ('maps.googleapis.com')
    def self.google_url
      @@google_url ||= 'maps.googleapis.com'
    end

    # The Google API URL
    #
    # @param [String] url
    #   the Google API URL
    def self.google_url=(url)
      @@google_url = url
    end

    # Use Google URL if key has been set else use Geonames URL
    #
    # @return [String]
    #   the Google or Geonames API URL
    def self.url
      use_google? ? google_url : geonames_url
    end

    # The Geonames API HTTP protocol
    #
    # @param [String] protocol
    #   the Geonames API HTTP procotol
    def self.geonames_protocol=(protocol)
      @@geonames_protocol = protocol
    end

    # The Geonames API HTTP protocol
    #
    # @return [String]
    #   the Geonames API HTTP protocol ('http')
    def self.geonames_protocol
      @@geonames_protocol ||= 'http'
    end

    # The Google API HTTP protocol
    #
    # @param [String] protocol
    #   the Google API HTTP procotol
    def self.google_protocol=(protocol)
      @@google_protocol = protocol
    end

    # The Google API HTTP protocol
    #
    # @return [String]
    #   the Google API HTTP protocol ('https')
    def self.google_protocol
      @@google_protocol ||= 'https'
    end

    # Use Google protocol if key has been set else use Geonames protocol
    #
    # @return [String]
    #   the Google or Geonames API protocol
    def self.protocol
      use_google? ? google_protocol : geonames_protocol
    end

    # The HTTP client that handles requests to Geonames and Google
    #
    # @return [Object]
    #   the HTTP client ({Timezone::NetHTTPClient Timezone::NetHTTPClient})
    def self.http_client
      @@http_client ||= Timezone::NetHTTPClient
    end

    # The HTTP client that handles requests to Geonames and Google
    #
    # @param [Object] client
    #   the HTTP client that handles requests to Geonames and Google
    #
    def self.http_client=(client)
      @@http_client = client
    end

    # The Geonames API username
    #
    # @return [String]
    #   the Geonames API username ('foo-bar')
    def self.username
      @@username ||= nil
    end

    # The Geonames API username
    #
    # @param [String] username
    #   the Geonames API username
    def self.username=(username)
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
