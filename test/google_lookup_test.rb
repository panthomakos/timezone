require 'timezone/configure'
require 'timezone/lookup/google'
require 'minitest/autorun'
require 'timecop'
require_relative 'http_test_client'

class GoogleLookupTest < ::Minitest::Unit::TestCase
  def setup
    Timezone::Configure.begin do |c|
      c.http_client = HTTPTestClient
      c.google_api_key = 'MTIzYWJj'
    end
  end

  def coordinates
    [-34.92771808058, 138.477041423321]
  end

  def lookup
    ::Timezone::Lookup::Google.new(Timezone::Configure)
  end

  def test_missing_api_key
    Timezone::Configure.begin{ |c| c.google_api_key = nil }
    assert_raises(::Timezone::Error::InvalidConfig){ lookup }
  ensure
    Timezone::Configure.begin{ |c| c.google_api_key = 'MTIzYWJj' }
  end

  def test_google_using_lat_lon_coordinates
    HTTPTestClient.body = File.open(mock_path + '/google_lat_lon_coords.txt').read

    assert_equal 'Australia/Adelaide', lookup.lookup(*coordinates)
  end

  def test_google_request_denied_read_lat_lon_coordinates
    HTTPTestClient.body = nil
    assert_raises Timezone::Error::Google, 'The provided API key is invalid.' do
      lookup.lookup(*coordinates)
    end
  end

  def test_url_non_enterprise
    Timecop.freeze(Time.at(1433347661)) do
      result = lookup.send(:url, '123', '123')
      assert_equal "/maps/api/timezone/json?location=123%2C123&timestamp=1433347661&key=MTIzYWJj", result
    end
  end

  def test_url_enterprise
    Timezone::Configure.begin do |c|
      c.google_client_id = '123&asdf'
    end

    Timecop.freeze(Time.at(1433347661)) do
      result = lookup.send(:url, '123', '123')
      assert_equal '/maps/api/timezone/json?location=123%2C123&timestamp=1433347661&client=123%26asdf&signature=B1TNSSvIw9Wvf_ZjjW5uRzGm4F4=', result
    end

  ensure
    Timezone::Configure.begin do |c|
      c.google_client_id = nil
    end
  end

  private

  def mock_path
    File.expand_path(File.join(File.dirname(__FILE__), 'mocks'))
  end
end
