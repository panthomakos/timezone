module Timezone
  # Configuration class for the Timezone gem.
  #
  #   Timezone::Configure.begin do |c| ... end
  #
  # c.username = username - the geonames username you use to access the geonames timezone API.
  #
  # Signup for a geonames username at http://www.geonames.org/login. Use that username to configure
  # your application for latitude and longitude based timezone searches. If you aren't going to
  # initialize timezone objects based on latitude and longitude then this configuration is not necessary.
  class Configure
    def self.url
      @@url ||= 'api.geonames.org'
    end

    def self.url= url
      @@url = url
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
