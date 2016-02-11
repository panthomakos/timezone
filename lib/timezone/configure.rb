require 'timezone/net_http_client'
require 'timezone/lookup'
require 'timezone/deprecate'

module Timezone
  # @deprecated `Timezone::Configure` will be removed in the release
  #   of the `timezone gem. Use `Timezone::Config` instead.
  class Configure
    DEPRECATE = '[DEPRECATED] `Timezone::Configure` will be removed ' \
      'in the release of the `timezone gem. Use `Timezone::Config` ' \
      'instead.'.freeze

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_api_key
      @google_api_key ||= nil
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_api_key=(api_key)
      @google_api_key = api_key
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_client_id
      @google_client_id ||= nil
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_client_id=(client)
      @google_client_id = client
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.use_google?
      !!google_api_key
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.use_google_enterprise?
      use_google? && !!google_client_id
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.lookup=(lookup)
      @lookup = lookup && lookup.new(self)
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.lookup
      return @lookup if @lookup

      use_google? ? google_lookup : geonames_lookup
    end

    class GoogleConfigMapper
      def initialize(config)
        @config = config
      end

      def protocol ; @config.protocol ; end
      def url ; @config.url ; end
      def http_client ; @config.http_client ; end
      def api_key ; @config.google_api_key ; end
      def client_id ; @config.google_client_id ; end
    end

    private_constant :GoogleConfigMapper

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_lookup
      @google_lookup ||=
        Timezone::Lookup::Google.new(GoogleConfigMapper.new(self))
    end

    class GeonamesConfigMapper
      def initialize(config)
        @config = config
      end

      def protocol ; @config.protocol ; end
      def url ; @config.url ; end
      def username ; @config.username ; end
      def http_client ; @config.http_client ; end
    end

    private_constant :GeonamesConfigMapper

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.geonames_lookup
      @geonames_lookup ||=
        Timezone::Lookup::Geonames.new(GeonamesConfigMapper.new(self))
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.geonames_url
      @@geonames_url ||= 'api.geonames.org'
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.geonames_url=(url)
      @@geonames_url = url
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.url=(url)
      self.geonames_url = url
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_url
      @@google_url ||= 'maps.googleapis.com'
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_url=(url)
      @@google_url = url
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.url
      use_google? ? google_url : geonames_url
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.geonames_protocol=(protocol)
      @@geonames_protocol = protocol
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.geonames_protocol
      @@geonames_protocol ||= 'http'
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_protocol=(protocol)
      @@google_protocol = protocol
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.google_protocol
      @@google_protocol ||= 'https'
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.protocol
      use_google? ? google_protocol : geonames_protocol
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.http_client
      @@http_client ||= Timezone::NetHTTPClient
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.http_client=(client)
      @@http_client = client
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.username
      @@username ||= nil
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.username=(username)
      @@username = username
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.begin
      Deprecate.call(self, :begin, DEPRECATE)
      yield self
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.replace(what, with = Hash.new)
      replacements # instantiate @@replacements
      @@replacements[what] = with[:with]
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.replacements
      @@replacements ||= {}
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.default_for_list
      @@default_list ||= nil
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.default_for_list=(*list)
      @@default_list = list.flatten!
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.order_list_by
      @@order_by ||= :utc_offset
    end

    # @deprecated `Timezone::Configure` will be removed in the release
    #   of the `timezone gem. Use `Timezone::Config` instead.
    def self.order_list_by=(order)
      @@order_by = order
    end
  end
end
