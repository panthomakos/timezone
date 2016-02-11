require 'timezone/lookup/geonames'
require 'minitest/autorun'
require_relative '../../http_test_client'

class TestGeonames < ::Minitest::Test
  parallelize_me!

  def coordinates
    [-34.92771808058, 138.477041423321]
  end

  def lookup
    config = OpenStruct.new
    config.username = 'timezone'
    config.http_client = HTTPTestClient

    Timezone::Lookup::Geonames.new(config)
  end

  def test_default_config
    assert_equal 'http', lookup.config.protocol
    assert_equal 'api.geonames.org', lookup.config.url
  end

  def test_missing_username
    assert_raises(::Timezone::Error::InvalidConfig) do
      Timezone::Lookup::Geonames.new(OpenStruct.new)
    end
  end

  def test_lookup
    mine = lookup
    mine.client.body = File.open(mock_path + '/lat_lon_coords.txt').read

    assert_equal 'Australia/Adelaide', mine.lookup(*coordinates)
  end

  def test_api_limit
    mine = lookup
    mine.client.body = File.open(mock_path + '/api_limit_reached.txt').read

    assert_raises Timezone::Error::GeoNames, 'api limit reached' do
      mine.lookup(*coordinates)
    end
  end

  private

  def mock_path
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        '..',
        '..',
        'mocks'
      )
    )
  end
end
