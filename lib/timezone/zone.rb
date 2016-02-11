require 'json'
require 'date'
require 'time'

require 'timezone/loader'
require 'timezone/error'
require 'timezone/configure'
require 'timezone/active_support'
require 'timezone/loader'

module Timezone
  class Zone
    include Comparable

    attr_reader :name

    alias to_s name

    def inspect
      "#<Timezone::Zone name: \"#{name}\">"
    end

    def exists?
      true
    end

    SOURCE_BIT = 0
    private_constant :SOURCE_BIT
    NAME_BIT = 1
    private_constant :NAME_BIT
    DST_BIT = 2
    private_constant :DST_BIT
    OFFSET_BIT = 3
    private_constant :OFFSET_BIT

    def initialize(name)
      if name.is_a?(Hash)
        legacy_initialize(name)
      else
        @name = name
      end
    end

    # @deprecated This method will be replaced with `Zone#name` in
    #   future versions of this gem.
    def zone
      warn '[DEPRECATED] `Zone#zone` will not be available in ' \
        'the next release of the `timezone` gem. Use `Zone#name` ' \
        'instead.'.freeze

      name
    end

    # @deprecated This method will be removed in the next release.
    def rules
      warn '[DEPRECATED] `Zone#rules` will not be available in ' \
        'the next release of the `timezone` gem.'.freeze

      private_rules
    end

    def legacy_initialize(options)
      warn '[DEPRECATED] Creating Zone objects using an options hash ' \
        'will be deprecated in the next release of the `timezone` gem. ' \
        'Use `Timezone::[]`, `Timezone::fetch` or `Timezone::lookup` ' \
        'instead.'.freeze

      if options.has_key?(:lat) && options.has_key?(:lon)
        options[:zone] = timezone_id options[:lat], options[:lon]
      elsif options.has_key?(:latlon)
        options[:zone] = timezone_id(*options[:latlon])
      end

      raise Timezone::Error::NilZone, 'No zone was found. Please specify a zone.' if options[:zone].nil?

      @name = options[:zone]
      private_rules
    end

    # @deprecated This functionality will be removed in the next release.
    def active_support_time_zone
      warn '[DEPRECATED] `Zone#active_support_time_zone` will be deprecated ' \
        'in the next release of the `timezone` gem. There will be no ' \
        'replacement.'.freeze

      @active_support_time_zone ||= Timezone::ActiveSupport.format(name)
    end

    # Returns the reference time in the timezone as a UTC time.
    #
    # @param reference [#to_time] the reference time
    # @return [Time] the time in the local timezone
    #
    # @note The resulting time is always a UTC time. If you would  like
    #       a time with the appropriate offset, use `#time_with_offset`
    #       instead.
    def time(reference)
      reference = sanitize(reference)

      reference.utc + utc_offset(reference)
    end

    alias utc_to_local time

    # Returns the UTC time for a given reference time in the timezone.
    #
    # @param reference [#to_time] the reference time
    # @return [Time] the time in UTC
    #
    # @note The UTC equivalent is a "best guess". There are cases where
    #       local times do not map to UTC at all (during a time skip
    #       forward). There are also cases where local times map to two
    #       separate UTC times (during a fall back). All of these cases
    #       are ignored here and the best (first) guess is used instead.
    def local_to_utc(reference)
      reference = sanitize(reference)

      reference.utc - rule_for_local(reference).rules.first[OFFSET_BIT]
    end

    # Returns the reference time in the timezone with the appropriate
    # offset.
    #
    # @param reference [#to_time] the reference time
    # @return [Time] the time in the local timezone with the appropriate
    #                offset
    def time_with_offset(reference)
      reference = sanitize(reference)

      utc = time(reference)
      offset = utc_offset(reference)
      Time.new(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec, offset)
    end

    # Whether or not the reference time in the timezone is in Daylight Savings
    # Time.
    #
    # @param reference [#to_time] the reference time
    # @return [Boolean] whether the timezone, at the given reference time, was
    #                   observing Daylight Savings Time
    def dst?(reference)
      reference = sanitize(reference)

      rule_for_utc(reference)[DST_BIT]
    end

    # Return the UTC offset (in seconds) for the reference time in the
    # timezone.
    #
    # @param reference [#to_time] the reference time
    # @return [Integer] the UTC offset (in seconds) in the local timezone
    def utc_offset(reference=Time.now)
      reference = sanitize(reference)

      rule_for_utc(reference)[OFFSET_BIT]
    end

    def <=>(zone)
      utc_offset <=> zone.utc_offset
    end

    class << self
      # @deprecated This method will be replaced with `Timezone.names`
      #   in future versions of this gem.
      def names
        warn '[DEPRECATED] `::Timezone::Zone.names` will be removed in ' \
          'the next gem release. Use `::Timezone.names` instead.'.freeze

        Loader.names
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
        list.each do |name|
          item = new(name)
          @zones << {
            :zone => item.name,
            :title => Configure.replacements[item.name] || item.name,
            :offset => item.utc_offset,
            :utc_offset => (item.utc_offset/(60*60)),
            :dst => item.dst?(now)
          }
        end
        @zones.sort_by! { |zone| zone[Configure.order_list_by] }
      end
    end

    private

    def private_rules
      @rules ||= Loader.load(name)
    end

    def sanitize(reference)
      reference.to_time
    end

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
      match = private_rules[index]

      utc = local-match[OFFSET_BIT]

      # If the UTC rule for the calculated UTC time does not map back to the
      # same rule, then we have a skip in time and there is no applicable rule.
      return RuleSet.new(:missing, [match]) if rule_for_utc(utc) != match

      # If the match is the last rule, then return it.
      return RuleSet.new(:single, [match]) if index == private_rules.length-1

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
      if utc > match[SOURCE_BIT] - match[OFFSET_BIT] + private_rules[index+1][OFFSET_BIT]
        RuleSet.new(:double, private_rules[index..(index+1)])
      else
        RuleSet.new(:single, [match])
      end
    end

    def rule_for_utc(time) #:nodoc:
      time = time.utc if time.respond_to?(:utc)
      time = time.to_i

      return private_rules[binary_search(time){ |t,r| match?(t,r) }]
    end

    # Find the first rule that matches using binary search.
    def binary_search(time, from=0, to=nil, &block)
      to = private_rules.length-1 if to.nil?

      return from if from == to

      mid = (from + to) / 2

      if block.call(time, private_rules[mid])
        return mid if mid == 0

        if !block.call(time, private_rules[mid-1])
          return mid
        else
          return binary_search(time, from, mid-1, &block)
        end
      else
        return binary_search(time, mid + 1, to, &block)
      end
    end

    def timezone_id(lat, lon) #:nodoc:
      Timezone::Configure.lookup.lookup(lat,lon)
    end
  end
end
