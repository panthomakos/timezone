require File.expand_path(File.dirname(__FILE__) + '/../lib/timezone')
require 'test/unit'

class TimezoneTest < Test::Unit::TestCase

  def test_valid_timezone
    assert_nothing_raised do
      Timezone.new :zone => 'Australia/Sydney'
    end
  end
  
  def test_nil_timezone
    assert_raise Timezone::Error::NilZone do
      Timezone.new :zone => nil
    end
  end
  
  def test_invalid_timezone
    assert_raise Timezone::Error::InvalidZone do
      Timezone.new :zone => 'Foo/Bar'
    end
  end
  
  def test_loading_GMT_timezone
    timezone = Timezone.new :zone => 'GMT'
    assert_equal Time.now.utc.to_i, timezone.time(Time.now).to_i
  end
  
  def test_loading_historical_time
    timezone = Timezone.new :zone => 'America/Los_Angeles'
    local = Time.strptime('2011-02-11T13:20:00Z', '%Y-%m-%dT%H:%M:%SZ')
    utc = Time.strptime('2011-02-11T21:20:00Z', '%Y-%m-%dT%H:%M:%SZ')
    assert_equal local.to_i, timezone.time(utc).to_i
  end
  
  def test_loading_half_hour_timezone
    timezone = Timezone.new :zone => 'Asia/Kathmandu'
    utc = Time.utc(2011, 1, 4, 3, 51, 29)
    local = Time.utc(2011, 1, 4, 9, 36, 29)
    assert_equal local.to_i, timezone.time(utc).to_i
  end
  
  def test_using_lat_lon_coordinates
    Timezone::Configure.begin { |c| c.username = 'timezone' }
    timezone = Timezone.new :latlon => [-34.92771808058, 138.477041423321]
    assert_equal 'Australia/Adelaide', timezone.zone
  end
  
  def test_australian_timezone_with_dst
    timezone = Timezone.new :zone => 'Australia/Adelaide'
    utc = Time.utc(2010, 12, 23, 19, 37, 15)
    local = Time.utc(2010, 12, 24, 6, 7, 15)
    assert_equal local.to_i, timezone.time(utc).to_i
  end
end