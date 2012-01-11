require File.expand_path(File.dirname(__FILE__) + '/../lib/timezone')
require File.expand_path(File.dirname(__FILE__) + '/../lib/timezone/zone')
require 'test/unit'

class TimezoneTest < Test::Unit::TestCase

  def test_valid_timezone
    assert_nothing_raised do
      Timezone::Zone.new :zone => 'Australia/Sydney'
    end
  end

  def test_nil_timezone
    assert_raise Timezone::Error::NilZone do
      Timezone::Zone.new :zone => nil
    end
  end

  def test_invalid_timezone
    assert_raise Timezone::Error::InvalidZone do
      Timezone::Zone.new :zone => 'Foo/Bar'
    end
  end

  def test_timezone_list
    list = Timezone::Zone.list "Australia/Sydney", "America/Chicago"
    assert list.is_a?(Array)
    assert list.count == 2
    assert list.first.is_a?(Hash)
    assert list.first[:zone] == "Australia/Sydney"
  end

  def test_timezone_custom_list_order
    Timezone::Configure.order_list_by = :title
    Timezone::Configure.replace "America/Chicago", with: "Chicago"
    list = Timezone::Zone.list "Australia/Sydney", "America/Chicago"
    assert list.first[:title] == "Australia/Sydney"
    assert list.last[:title] == "Chicago"
    assert list.last[:zone] == "America/Chicago"
  end

  def test_timezone_default_list
    Timezone::Configure.default_for_list = "America/Chicago", "Australia/Sydney"
    list = Timezone::Zone.list
    assert list.count == 2
    assert list.first.has_value? "Australia/Sydney"
  end

  def test_timezone_names
    zones = Timezone::Zone.names
    assert zones.is_a?(Array)
    assert zones.count > 0
    assert zones.include? "Australia/Sydney"
  end

  def time_timezone_equivalence
    gmt = Timezone::Zone.new :zone => 'GMT'
    australia = Timezone::Zone.new :zone => 'Australia/Sydney'
    assert gmt == gmt
    assert gmt <= australia
    assert gmt < australia
  end

  def test_getting_utc_offset
    assert_equal 36000, Timezone::Zone.new(:zone => 'Australia/Sydney').utc_offset(Time.parse('2011-06-05'))
    assert_equal -25200, Timezone::Zone.new(:zone => 'America/Los_Angeles').utc_offset(Time.parse('2011-06-05'))
    assert_equal 20700, Timezone::Zone.new(:zone => 'Asia/Kathmandu').utc_offset(Time.parse('2011-06-05'))

    assert_equal -18000, Timezone::Zone.new(:zone => 'America/New_York').utc_offset(Time.parse('2011-01-11'))
    assert_equal -14400, Timezone::Zone.new(:zone => 'America/New_York').utc_offset(Time.parse('2011-06-11'))
  end

  def test_loading_GMT_timezone
    timezone = Timezone::Zone.new :zone => 'GMT'
    assert_equal Time.now.utc.to_i, timezone.time(Time.now).to_i
  end

  def test_loading_historical_time
    timezone = Timezone::Zone.new :zone => 'America/Los_Angeles'
    local = Time.strptime('2011-02-11T13:20:00Z', '%Y-%m-%dT%H:%M:%SZ')
    utc = Time.strptime('2011-02-11T21:20:00Z', '%Y-%m-%dT%H:%M:%SZ')
    assert_equal local.to_i, timezone.time(utc).to_i
  end

  def test_loading_half_hour_timezone
    timezone = Timezone::Zone.new :zone => 'Asia/Kathmandu'
    utc = Time.utc(2011, 1, 4, 3, 51, 29)
    local = Time.utc(2011, 1, 4, 9, 36, 29)
    assert_equal local.to_i, timezone.time(utc).to_i
  end

  def test_using_lat_lon_coordinates
    Timezone::Configure.begin { |c| c.username = 'timezone' }
    timezone = Timezone::Zone.new :latlon => [-34.92771808058, 138.477041423321]
    assert_equal 'Australia/Adelaide', timezone.zone
  end

  def test_australian_timezone_with_dst
    timezone = Timezone::Zone.new :zone => 'Australia/Adelaide'
    utc = Time.utc(2010, 12, 23, 19, 37, 15)
    local = Time.utc(2010, 12, 24, 6, 7, 15)
    assert_equal local.to_i, timezone.time(utc).to_i
  end

  def test_configure_url_default
    assert_equal 'ws.geonames.org', Timezone::Configure.url
  end

  def test_configure_url_custom
    Timezone::Configure.begin { |c| c.url = 'www.newtimezoneserver.com' }
    assert_equal 'www.newtimezoneserver.com', Timezone::Configure.url
    # clean up url after test
    Timezone::Configure.begin { |c| c.url = nil }
  end

end
