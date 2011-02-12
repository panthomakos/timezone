require 'json'
require 'date'
require 'time'
require 'net/http'

class Timezone
  attr_accessor :rules, :zone

  # Configuration class for the Timezone gem.
  #
  # Timezone::Configure.begin do |c| ... end
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

  # Error messages that can be raised by this gem. To catch any related error message, simply use Error::Base.
  #
  # begin
  #   ...
  # rescue Timezone::Error::Base => e
  #   puts "Timezone Error: #{e.message}"
  # end
  module Error
    class Base < StandardError; end
    class InvalidZone < Base; end
    class NilZone < Base; end
    class GeoNames < Base; end
    class ParseTime < Base; end
  end
    
  # Create a new Timezone object.
  # 
  # Timezone.new(options)
  # :zone       - The actual name of the zone. For example, Australia/Sydney or Americas/Los_Angeles.
  # :lat, :lon  - The latitude and longitude of the location.
  # :latlon     - The array of latitude and longitude of the location.
  #
  # If a latitude and longitude is passed in, the Timezone object will do a lookup for the actual zone
  # name and then use that as a reference. It will then load the appropriate json timezone information
  # for that zone, and compile a list of the timezone rules.
  def initialize options
    if options.has_key?(:lat) && options.has_key?(:lon)
      options[:zone] = timezone_id options[:lat], options[:lon]
    elsif options.has_key?(:latlon)
      options[:zone] = timezone_id *options[:latlon]
    end
    
    raise Error::NilZone, 'No zone was found. Please specify a zone.' if options[:zone].nil?
    
    file = File.join 'data', "#{options[:zone]}.json"
    raise Error::InvalidZone, "'#{options[:zone]}' is not a valid zone." unless File.exists?(file)

    data = JSON.parse(open(file).read)
    @rules = data['zone']
    @zone = data['_zone'] || options[:zone]
  end
  
  # Determine the time in the timezone.
  #
  # timezone.time(reference)
  # reference - The Time you want to convert.
  #
  # The reference is converted to a UTC equivalent. That UTC equivalent is then used to lookup the appropriate
  # offset in the timezone rules. Once the offset has been found that offset is added to the reference UTC time
  # to calculate the reference time in the timezone.
  def time reference
    reference = reference.utc
    rule = rules.detect{ |rule| _parsetime(rule['_from']) <= reference && _parsetime(rule['_to']) >= reference }
    reference + rule['offset']
  end
  
  private
  
  def timezone_id lat, lon #:nodoc:
    begin
      response = Net::HTTP.get('ws.geonames.org', "/timezoneJSON?lat=#{lat}&lng=#{lon}&username=#{Configure.username}")
      JSON.parse(response)['timezoneId']
    rescue Exception => e
      raise Error::GeoNames, e.message
    end
  end
  
  def _parsetime time #:nodoc:
    begin
      Time.strptime(time, "%Y-%m-%dT%H:%M:%SZ")
    rescue Exception => e
      raise Error::ParseTime, e.message
    end
  end
end