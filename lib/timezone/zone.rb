require 'json'
require 'date'
require 'time'
require 'net/http'
require File.expand_path(File.dirname(__FILE__) + '/error')
require File.expand_path(File.dirname(__FILE__) + '/configure')

module Timezone
  class Zone
    include Comparable
    attr_accessor :rules, :zone
    
    # Create a new Timezone object.
    # 
    #   Timezone.new(options)
    #
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

      raise Timezone::Error::NilZone, 'No zone was found. Please specify a zone.' if options[:zone].nil?

      file = File.join File.expand_path(File.dirname(__FILE__)+'/../../data'), "#{options[:zone]}.json"
      raise Timezone::Error::InvalidZone, "'#{options[:zone]}' is not a valid zone." unless File.exists?(file)

      data = JSON.parse(open(file).read)
      @rules = data['zone']
      @zone = data['_zone'] || options[:zone]
    end

    # Determine the time in the timezone.
    #
    #   timezone.time(reference)
    #
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
    
    # Get the current UTC offset in seconds for this timezone.
    #
    #   timezone.utc_offset
    def utc_offset
      @rules.last['offset']-(@rules.last['dst'] ? 3600 : 0)
    end
    
    def <=> zone #:nodoc:
      utc_offset <=> zone.utc_offset
    end
    
    private

    def timezone_id lat, lon #:nodoc:
      begin
        response = Net::HTTP.get('ws.geonames.org', "/timezoneJSON?lat=#{lat}&lng=#{lon}&username=#{Timezone::Configure.username}")
        JSON.parse(response)['timezoneId']
      rescue Exception => e
        raise Timezone::Error::GeoNames, e.message
      end
    end

    def _parsetime time #:nodoc:
      begin
        Time.strptime(time, "%Y-%m-%dT%H:%M:%SZ")
      rescue Exception => e
        raise Timezone::Error::ParseTime, e.message
      end
    end
  end
end