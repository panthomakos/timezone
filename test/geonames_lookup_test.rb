require 'timezone/configure'
require 'timezone/lookup/geonames'
require 'test/unit'
require_relative 'http_test_client'

class GeonamesLookupTest < ::Test::Unit::TestCase
  def setup
    Timezone::Configure.begin do |c|
      c.http_client = HTTPTestClient
      c.username = 'timezone'
    end
  end

  def coordinates
    [-34.92771808058, 138.477041423321]
  end

  def lookup
    ::Timezone::Lookup::Geonames.new(Timezone::Configure)
  end

  def test_lookup
    HTTPTestClient.body = File.open(mock_path + '/lat_lon_coords.txt').read

    assert_equal 'Australia/Adelaide', lookup.lookup(*coordinates)
  end

  def test_api_limit
    HTTPTestClient.body = File.open(mock_path + '/api_limit_reached.txt').read

    assert_raise Timezone::Error::GeoNames, 'api limit reached' do
      lookup.lookup(*coordinates)
    end
  end

  private

  def mock_path
    File.expand_path(File.join(File.dirname(__FILE__), 'mocks'))
  end
end
