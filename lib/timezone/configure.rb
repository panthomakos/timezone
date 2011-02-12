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
    def self.username
      @@username
    end
    
    def self.username= username
      @@username = username
    end
    
    def self.begin
      yield self
    end
  end
end