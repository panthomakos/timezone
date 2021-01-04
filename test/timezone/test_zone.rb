# frozen_string_literal: true

require 'timecop'
require 'timezone/zone'
require 'minitest/autorun'

class TestZone < ::Minitest::Test
  parallelize_me!

  def zone(name)
    Timezone::Zone.new(name)
  end

  def utc_offset(name, year, month, day)
    zone(name).utc_offset(Time.new(year, month, day).freeze)
  end

  def dst?(name, year, month, day)
    zone(name).dst?(Time.new(year, month, day).freeze)
  end

  def la
    @la ||= zone('America/Los_Angeles')
  end

  def paris
    @paris ||= zone('Europe/Paris')
  end

  def test_name
    assert_equal 'America/Los_Angeles', la.name
    assert_equal 'Europe/Paris', paris.name
  end

  def test_abbr
    assert_equal 'PDT', la.abbr(Time.new(2011, 6, 5).freeze)
    assert_equal 'PST', la.abbr(Time.new(2011, 11, 20).freeze)
  end

  def test_valid?
    assert la.valid?
    assert paris.valid?
  end

  def test_to_s
    assert_equal 'America/Los_Angeles', la.to_s
    assert_equal 'Europe/Paris', paris.to_s
  end

  def test_inspect
    assert_equal(
      '#<Timezone::Zone name: "America/Los_Angeles">',
      la.inspect
    )

    assert_equal(
      '#<Timezone::Zone name: "Europe/Paris">',
      paris.inspect
    )
  end

  def test_comparable
    assert paris > la
    assert la < paris
    assert la == zone('America/Los_Angeles')

    assert_nil paris <=> 8
  end

  def test_est5edt_dst_now
    Timecop.freeze(Time.new(2012, 2, 2, 0, 0, 0)) do
      refute zone('EST5EDT').dst?(Time.now)
    end
    Timecop.freeze(Time.new(2013, 6, 6, 0, 0, 0)) do
      assert zone('EST5EDT').dst?(Time.now)
    end
  end

  def test_utc_offsets
    assert_equal(36_000, utc_offset('Australia/Sydney', 2011, 6, 5))
    assert_equal(-25_200, utc_offset('America/Los_Angeles', 2011, 6, 5))
    assert_equal(20_700, utc_offset('Asia/Kathmandu', 2011, 6, 5))
    assert_equal(-18_000, utc_offset('America/New_York', 2011, 1, 11))
    assert_equal(-14_400, utc_offset('America/New_York', 2011, 6, 11))
  end

  def test_dst
    refute dst?('Australia/Sydney', 2011, 6, 5)
    assert dst?('America/Los_Angeles', 2011, 6, 5)
    refute dst?('Asia/Kathmandu', 2011, 6, 5)

    refute dst?('America/New_York', 2011, 1, 11)
    assert dst?('America/New_York', 2011, 6, 11)
  end

  def test_gmt_timezone
    t = Time.now.freeze
    assert_equal t.dup.utc.to_i, zone('GMT').utc_to_local(t).to_i
  end

  def test_historical_time
    timezone = zone('America/Los_Angeles')
    local = Time.strptime('2011-02-11T13:20:00Z', '%Y-%m-%dT%H:%M:%SZ')
    utc = Time.strptime('2011-02-11T21:20:00Z', '%Y-%m-%dT%H:%M:%SZ')

    assert_equal local.to_i, timezone.utc_to_local(utc).to_i
  end

  # http://www.timeanddate.com/worldclock/clockchange.html?n=137&year=2011
  def test_historical_time_change_in_la_forward
    local = Time.strptime('2011-03-13T01:59:59 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    utc = Time.strptime('2011-03-13T09:59:59 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    assert_equal local.to_i, zone('America/Los_Angeles').utc_to_local(utc).to_i

    local = Time.strptime('2011-03-13T03:00:00 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    utc = Time.strptime('2011-03-13T10:00:00 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    assert_equal local.to_i, zone('America/Los_Angeles').time(utc).to_i
  end

  # http://www.timeanddate.com/worldclock/clockchange.html?n=137&year=2011
  def test_historical_time_change_in_la_backward
    local = Time.strptime('2011-11-06T01:59:59 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    utc = Time.strptime('2011-11-06T08:59:59 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    assert_equal local.to_i, zone('America/Los_Angeles').time(utc).to_i

    local = Time.strptime('2011-11-06T01:00:00 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    utc = Time.strptime('2011-11-06T09:00:00 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    assert_equal local.to_i, zone('America/Los_Angeles').time(utc).to_i
  end

  # http://www.timeanddate.com/worldclock/clockchange.html?n=2364&year=1940
  def test_historical_time_change_in_hebron
    local = Time.strptime('1940-06-01T01:59:59 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    utc = Time.strptime('1940-05-31T23:59:59 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    assert_equal local.to_i, zone('Asia/Hebron').time(utc).to_i

    local = Time.strptime('1940-06-01T03:00:00 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    utc = Time.strptime('1940-06-01T00:00:00 UTC', '%Y-%m-%dT%H:%M:%S %Z')
    assert_equal local.to_i, zone('Asia/Hebron').time(utc).to_i
  end

  def test_half_hour_timezone
    utc = Time.utc(2011, 1, 4, 3, 51, 29)
    local = Time.utc(2011, 1, 4, 9, 36, 29)
    assert_equal local.to_i, zone('Asia/Kathmandu').time(utc).to_i
  end

  # Testing is done with strings since two times can be equivalent even if
  # their offsets do not match, and we want to test that the time and offsets
  # are equivalent.
  def test_time_with_offset
    utc = Time.utc(2011, 1, 4, 3, 51, 29)
    local = Time.new(2011, 1, 4, 9, 36, 29, 20_700)
    assert_equal local.to_s, zone('Asia/Kathmandu').time_with_offset(utc).to_s

    utc = Time.utc(2014, 12, 15, 22, 0, 0)
    local = Time.new(2014, 12, 15, 14, 0, 0, '-08:00')
    assert_equal(
      local.to_s,
      zone('America/Los_Angeles').time_with_offset(utc).to_s
    )

    utc = Time.utc(2014, 4, 5, 22, 0, 0)
    local = Time.new(2014, 4, 5, 15, 0, 0, '-07:00')
    assert_equal(
      local.to_s,
      zone('America/Los_Angeles').time_with_offset(utc).to_s
    )
  end

  def test_time_with_offset_and_fractional_seconds
    utc = Time.utc(2011, 1, 4, 3, 51, 29.123)
    time_with_offset = zone('Asia/Kathmandu').time_with_offset(utc)
    assert_equal 123_000, time_with_offset.usec

    utc = Time.utc(2011, 1, 4, 3, 51, 29, 123_456)
    time_with_offset = zone('Asia/Kathmandu').time_with_offset(utc)
    assert_equal 123_456, time_with_offset.usec
  end

  def test_australian_timezone_with_dst
    utc = Time.utc(2010, 12, 23, 19, 37, 15)
    local = Time.utc(2010, 12, 24, 6, 7, 15)
    assert_equal local.to_i, zone('Australia/Adelaide').time(utc).to_i
  end

  def test_local_to_utc
    timezone = zone('America/Los_Angeles')

    # Time maps to two rules - we pick the first
    local = Time.utc(2015, 11, 1, 1, 50, 0).freeze
    utc = Time.utc(2015, 11, 1, 8, 50, 0).freeze
    assert_equal(utc.to_s, timezone.local_to_utc(local).to_s)

    # Time is above the maximum - we pick the last rule
    local = Time.utc(3000, 1, 1, 0, 0, 0).freeze
    utc = Time.utc(3000, 1, 1, 8, 0, 0).freeze
    assert_equal(utc.to_s, timezone.local_to_utc(local).to_s)

    # Time maps to a single rule - we pick that rule
    local = Time.utc(2015, 11, 1, 0, 1, 0).freeze
    utc = Time.utc(2015, 11, 1, 7, 1, 0).freeze
    assert_equal(utc.to_s, timezone.local_to_utc(local).to_s)

    # Time is missing - we pick the first closest rule
    local = Time.utc(2015, 3, 8, 2, 50, 0).freeze
    utc = Time.utc(2015, 3, 8, 9, 50, 0).freeze
    assert_equal(utc.to_s, timezone.local_to_utc(local).to_s)
  end

  def test_utc_offset_without_dst
    timezone = zone('Europe/Helsinki')

    # just before DST starts
    utc = Time.utc(2012, 3, 25, 0, 59, 59)
    assert_equal 7200, timezone.utc_offset(utc)

    # on the second DST ends
    utc = Time.utc(2012, 10, 28, 1, 0, 0)
    assert_equal 7200, timezone.utc_offset(utc)
  end

  def test_utc_offset_with_dst
    timezone = zone('Europe/Helsinki')
    # on the second DST starts
    utc = Time.utc(2012, 3, 25, 1, 0, 0)
    assert_equal timezone.utc_offset(utc), 10_800

    # right before DST end
    utc = Time.utc(2012, 10, 28, 0, 59, 59)
    assert_equal timezone.utc_offset(utc), 10_800
  end

  EQUIVALENCE_METHODS = %i[
    time
    local_to_utc
    time_with_offset
    dst?
    utc_offset
  ].freeze

  def check_equivalence(name, time, other)
    tz = zone(name)

    EQUIVALENCE_METHODS.each do |m|
      assert_equal(tz.public_send(m, time), tz.public_send(m, other))
    end
  end

  def test_date_equivalence
    time = Time.new(2011, 2, 3, 0, 0, 0)
    date = Date.new(2011, 2, 3)

    check_equivalence('America/Los_Angeles', time, date)

    time = Time.new(2011, 6, 3, 0, 0, 0)
    date = Date.new(2011, 6, 3)

    check_equivalence('America/Los_Angeles', time, date)
  end

  def test_datetime_equivalence
    assert_equal 'UTC', Time.now.zone, 'This test must be run in UTC'

    time = Time.new(2011, 2, 3, 13, 5, 0)
    datetime = DateTime.new(2011, 2, 3, 13, 5, 0, 0)

    check_equivalence('America/Los_Angeles', time, datetime)

    time = Time.new(2011, 6, 3, 13, 5, 0)
    datetime = DateTime.new(2011, 6, 3, 13, 5, 0, 0)

    check_equivalence('America/Los_Angeles', time, datetime)
  end
end
