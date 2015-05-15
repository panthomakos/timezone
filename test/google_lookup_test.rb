require 'timezone/configure'
require 'timezone/lookup/google'
require 'minitest/autorun'
require_relative 'http_test_client'

class GoogleLookupTest < ::Minitest::Unit::TestCase
  def setup
    Timezone::Configure.begin do |c|
      c.http_client = HTTPTestClient
      c.google_api_key = '123abc'
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
    Timezone::Configure.begin{ |c| c.google_api_key = '123abc' }
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

  private

  def mock_path
    File.expand_path(File.join(File.dirname(__FILE__), 'mocks'))
  end
end
