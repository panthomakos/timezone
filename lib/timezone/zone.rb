# frozen_string_literal: true

require 'json'
require 'date'
require 'time'

require 'timezone/loader'
require 'timezone/error'
require 'timezone/loader'

module Timezone
  # This object represents a real-world timezone. Each instance provides
  # methods for converting UTC times to the local timezone and local
  # times to UTC for any historical, present or future times.
  class Zone
    include Comparable

    # @return [String] the timezone name
    attr_reader :name

    alias to_s name

    # @return [String] a developer friendly representation of the object
    def inspect
      "#<Timezone::Zone name: \"#{name}\">"
    end

    # If this is a valid timezone.
    #
    # @return [true] if this is a valid timezone
    def valid?
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

    # Create a new timezone object using the timezone name.
    #
    # @param name [String] the timezone name
    # @return [Timezone::Zone]
    def initialize(name)
      @name = name
    end

    # Converts the given time to the local timezone and does not include
    # a UTC offset in the result.
    #
    # @param time [#to_time] the source time
    # @return [Time] the time in the local timezone
    #
    # @note The resulting time is always a UTC time. If you would  like
    #       a time with the appropriate offset, use `#time_with_offset`
    #       instead.
    def utc_to_local(time)
      time = sanitize(time)

      (time + utc_offset(time)).utc
    end

    alias time utc_to_local

    # Converts the given local time to the UTC equivalent.
    #
    # @param time [#to_time] the local time
    # @return [Time] the time in UTC
    #
    # @note The UTC equivalent is a "best guess". There are cases where
    #   local times do not map to UTC at all (during a time skip forward).
    #   There are also cases where local times map to two distinct UTC
    #   times (during a fall back). All of these cases are approximated
    #   in this method and the first possible result is used instead.
    #
    # @note A note about the handling of time arguments.
    #
    #   Because the UTC offset of a `Time` object in Ruby is not
    #   equivalent to a single timezone, the `time` argument in this
    #   method is first converted to a UTC equivalent before being
    #   used as a local time.
    #
    #   This prevents confusion between historical UTC offsets and the UTC
    #   offset that the `Time` object provides. For instance, if I pass
    #   a "local" time with offset `+8` but the timezone actually had
    #   an offset of `+9` at the given historical time, there is an
    #   inconsistency that must be resolved.
    #
    #   Did the user make a mistake; or is the offset intentional?
    #
    #   One approach to solving this problem would be to raise an error,
    #   but this means that the user then needs to calculate the
    #   appropriate local offset and append that to a UTC time to satisfy
    #   the function. This is impractical because the offset can already
    #   be calculated by this library. The user should only need to
    #   provide a time without an offset!
    #
    #   To resolve this inconsistency, the solution I chose was to scrub
    #   the offset. In the case where an offset is provided, the time is
    #   just converted to the UTC equivalent (without an offset). The
    #   resulting time is used as the local reference time.
    #
    #   For example, if the time `08:00 +2` is passed to this function,
    #   the local time is assumed to be `06:00`.
    def local_to_utc(time)
      time = sanitize(time)

      (time - rule_for_local(time).rules.first[OFFSET_BIT]).utc
    end

    # Converts the given time to the local timezone and includes the UTC
    # offset in the result.
    #
    # @param time [#to_time] the source time
    # @return [Time] the time in the local timezone with the UTC offset
    def time_with_offset(time)
      time = sanitize(time)

      utc = utc_to_local(time)
      offset = utc_offset(time)

      Time.new(
        utc.year,
        utc.month,
        utc.day,
        utc.hour,
        utc.min,
        utc.sec + utc.subsec,
        offset
      )
    end

    # The timezone abbreviation, at the given time.
    #
    # @param time [#to_time] the source time
    # @return [String] the timezone abbreviation, at the given time
    def abbr(time)
      time = sanitize(time)

      rule_for_utc(time)[NAME_BIT]
    end

    # If, at the given time, the timezone was observing Daylight Savings.
    #
    # @param time [#to_time] the source time
    # @return [Boolean] whether the timezone, at the given time, was
    #                   observing Daylight Savings Time
    def dst?(time)
      time = sanitize(time)

      rule_for_utc(time)[DST_BIT]
    end

    # Return the UTC offset (in seconds) for the given time.
    #
    # @param time [#to_time] (Time.now) the source time
    # @return [Integer] the UTC offset (in seconds) in the local timezone
    def utc_offset(time = nil)
      time ||= Time.now
      time = sanitize(time)

      rule_for_utc(time)[OFFSET_BIT]
    end

    # Compare one timezone with another based on current UTC offset.
    #
    # @param other [Timezone::Zone] the other timezone
    #
    # @return [-1, 0, 1, nil] comparison based on current `utc_offset`.
    def <=>(other)
      return nil unless other.respond_to?(:utc_offset)

      utc_offset <=> other.utc_offset
    end

    private

    def sanitize(time)
      time.to_time
    end

    # Does the given time (in seconds) match this rule?
    #
    # Each rule has a SOURCE bit which is the number of seconds, since the
    # Epoch, up to which the rule is valid.
    def match?(seconds, rule) #:nodoc:
      seconds <= rule[SOURCE_BIT]
    end

    RuleSet = Struct.new(:type, :rules)
    private_constant :RuleSet

    def rule_for_local(local)
      local = local.to_i
      rules = Loader.load(name)

      # For each rule, convert the local time into the UTC equivalent for
      # that rule offset, and then check if the UTC time matches the rule.
      index =
        binary_search(rules, local) do |t, r|
          match?(t - r[OFFSET_BIT], r)
        end
      match = rules[index]

      utc = local - match[OFFSET_BIT]

      # If the UTC rule for the calculated UTC time does not map back to the
      # same rule, then we have a skip in time and there is no applicable rule.
      return RuleSet.new(:missing, [match]) if rule_for_utc(utc) != match

      # If the match is the last rule, then return it.
      return RuleSet.new(:single, [match]) if index == rules.length - 1

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
      last_hour =
        match[SOURCE_BIT] -
        match[OFFSET_BIT] +
        rules[index + 1][OFFSET_BIT]

      if utc > last_hour
        RuleSet.new(:double, rules[index..(index + 1)])
      else
        RuleSet.new(:single, [match])
      end
    end

    def rule_for_utc(time)
      time = time.to_i
      rules = Loader.load(name)

      rules[binary_search(rules, time) { |t, r| match?(t, r) }]
    end

    # Find the first rule that matches using binary search.
    def binary_search(rules, time, from = 0, to = nil, &block)
      to = rules.length - 1 if to.nil?

      return from if from == to

      mid = (from + to).div(2)

      unless yield(time, rules[mid])
        return binary_search(rules, time, mid + 1, to, &block)
      end

      return mid if mid.zero?

      return mid unless yield(time, rules[mid - 1])

      binary_search(rules, time, from, mid - 1, &block)
    end
  end
end
