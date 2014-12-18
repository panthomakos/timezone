require 'json'
require 'date'
require 'time'

require 'timezone/loader'
require 'timezone/error'
require 'timezone/configure'
require 'timezone/active_support'

module Timezone
  class Zone
    include Comparable
    attr_reader :rules, :zone

    SOURCE_BIT = 0
    NAME_BIT = 1
    DST_BIT = 2
    OFFSET_BIT = 3

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

      @zone = options[:zone]
      @rules = Timezone::Loader.load(@zone)
    end

    def active_support_time_zone
      @active_support_time_zone ||= Timezone::ActiveSupport.format(@zone)
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
    def time(reference)
      reference.utc + utc_offset(reference)
    end

    alias :utc_to_local :time

    # Determine the UTC time for a given time in the timezone.
    #
    #     timezone.local_to_utc(time)
    #
    # The UTC equivalent is a "best guess". There are cases where local times do not map to UTC
    # at all (during a time skip forward). There are also cases where local times map to two
    # separate UTC times (during a fall back). All of these cases are ignored here and the best
    # (first) guess is used instead.
    def local_to_utc(time)
      time.utc - rule_for_local(time).rules.first[OFFSET_BIT]
    end

    # Determine the time in the timezone w/ the appropriate offset.
    #
    #     timezone.time_with_offset(reference)
    #
    # reference - the `Time` you want to convert.
    #
    # The reference is converted to a UTC equivalent. That UTC equivalent is
    # then used to lookup the appropriate offset in the timezone rules. Once the
    # offset has been found, that offset is added to the reference UTC time
    # to calculate the reference time in the timezone. The offset is then
    # appended to put the time object into the proper offset.
    def time_with_offset(reference)
      utc = time(reference)
      offset = utc_offset(reference)
      Time.new(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec, offset)
    end

    # Whether or not the time in the timezone is in DST.
    def dst?(reference)
      rule_for_utc(reference)[DST_BIT]
    end

    # Get the current UTC offset in seconds for this timezone.
    #
    #   timezone.utc_offset(reference)
    def utc_offset(reference=Time.now)
      rule_for_utc(reference)[OFFSET_BIT]
    end

    def <=>(zone) #:nodoc:
      utc_offset <=> zone.utc_offset
    end

    class << self
      # Instantly grab all possible time zone names.
      def names
        Timezone::Loader.names
      end

      # Get a list of specified timezones and the basic information accompanying that zone
      #
      #   zones = Timezone::Zone.list(*zones)
      #
      # zones - An array of timezone names. (i.e. Timezone::Zones.list("America/Chicago", "Australia/Sydney"))
      #
      # The result is a Hash of timezones with their title, offset in seconds, UTC offset, and if it uses DST.
      #
      def list(*args)
        args = nil if args.empty? # set to nil if no args are provided
        zones = args || Configure.default_for_list || self.names # get default list
        list = self.names.select { |name| zones.include? name } # only select zones if they exist

        @zones = []
        now = Time.now
        list.each do |zone|
          item = Zone.new(zone: zone)
          @zones << {
            :zone => item.zone,
            :title => Configure.replacements[item.zone] || item.zone,
            :offset => item.utc_offset,
            :utc_offset => (item.utc_offset/(60*60)),
            :dst => item.dst?(now)
          }
        end
        @zones.sort_by! { |zone| zone[Configure.order_list_by] }
      end
    end

    private

    # Does the given time (in seconds) match this rule?
    #
    # Each rule has a SOURCE bit which is the number of seconds, since the
    # Epoch, up to which the rule is valid.
    def match?(seconds, rule) #:nodoc:
      seconds <= rule[SOURCE_BIT]
    end

    RuleSet = Struct.new(:type, :rules)

    def rule_for_local(local)
      local = local.utc if local.respond_to?(:utc)
      local = local.to_i

      # For each rule, convert the local time into the UTC equivalent for
      # that rule offset, and then check if the UTC time matches the rule.
      index = binary_search(local){ |t,r| match?(t-r[OFFSET_BIT], r) }
      match = @rules[index]

      utc = local-match[OFFSET_BIT]

      # If the UTC rule for the calculated UTC time does not map back to the
      # same rule, then we have a skip in time and there is no applicable rule.
      return RuleSet.new(:missing, [match]) if rule_for_utc(utc) != match

      # If the match is the last rule, then return it.
      return RuleSet.new(:single, [match]) if index == @rules.length-1

      # If the UTC equivalent time falls within the last hour(s) of the time
      # change which were replayed during a fall-back in time, then return
      # the matched rule and the next one.
      #
      # Example:
      #
      #     rules = [
      #       [ 8:00 UTC, -1 ], # UTC-1 up to and including 8:00 UTC
      #       [ 14:00 UTC, -2 ], # UTC-2 up to and including 14:00 UTC
      #     ]
      #
      #     6:50 local (7:50 UTC) by the first rule
      #     6:50 local (8:50 UTC) by the second rule
      #
      #     Since both rules provide valid mappings for the local time,
      #     we need to return both values.
      if utc > match[SOURCE_BIT] - match[OFFSET_BIT] + @rules[index+1][OFFSET_BIT]
        RuleSet.new(:double, @rules[index..(index+1)])
      else
        RuleSet.new(:single, [match])
      end
    end

    def rule_for_utc(time) #:nodoc:
      time = time.utc if time.respond_to?(:utc)
      time = time.to_i

      return @rules[binary_search(time){ |t,r| match?(t,r) }]
    end

    # Find the first rule that matches using binary search.
    def binary_search(time, from=0, to=nil, &block)
      to = @rules.length-1 if to.nil?

      return from if from == to

      mid = (from + to) / 2

      if block.call(time, @rules[mid])
        return mid if mid == 0

        if !block.call(time, @rules[mid-1])
          return mid
        else
          return binary_search(time, from, mid-1, &block)
        end
      else
        return binary_search(time, mid + 1, to, &block)
      end
    end

    def timezone_id lat, lon #:nodoc:
      Timezone::Configure.lookup.lookup(lat,lon)
    end
  end
end
