require 'timezone/lookup/geonames'
require 'minitest/autorun'
require_relative '../../http_test_client'

class TestGeonames < ::Minitest::Test
  parallelize_me!

  def coordinates
    [-34.92771808058, 138.477041423321]
  end

  def etc_data
    {
      arctic: { coordinates: [89, 40], name: 'Etc/GMT-3' },
      atlantic: { coordinates: [0, 0], name: 'Etc/UTC' },
      norfolk: { coordinates: [-29, 167], name: 'Etc/GMT-11' }
    }
  end

  def lookup(&_block)
    config = OpenStruct.new
    config.username = 'timezone'
    config.request_handler = HTTPTestClient
    yield config if block_given?

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

  def test_lookup_with_etc
    etc_data.each do |key, data|
      mine = lookup { |c| c.offset_etc_zones = true }
      mine.client.body = File.open(
        mock_path + "/lat_lon_coords_#{key}.txt"
      ).read

      assert_equal data[:name], mine.lookup(*data[:coordinates])
    end
  end

  def test_wrong_offset
    mine = lookup { |c| c.offset_etc_zones = true }
    mine.client.body = File.open(
      mock_path + '/lat_lon_coords_wrong_offset.txt'
    ).read

    assert_nil mine.lookup(*coordinates)
  end

  def test_lookup_etc_without_option
    mine = lookup
    assert_nil mine.lookup(*etc_data[:atlantic][:coordinates])
  end

  def assert_exception(lookup, message)
    exception = false

    begin
      lookup.lookup(*coordinates)
    rescue Timezone::Error::GeoNames => e
      exception = true
      assert_equal message, e.message
    end

    assert(exception)
  end

  def test_api_limit
    mine = lookup
    mine.client.body = File.open(mock_path + '/api_limit_reached.json').read

    assert_exception(
      mine,
      'the daily limit of 30000 credits for XXXXX has been exceeded. ' \
        'Please throttle your requests or use the commercial service.'
    )
  end

  def test_invalid_latlong
    mine = lookup
    mine.client.body = File.open(mock_path + '/invalid_latlong.json').read

    assert_exception(mine, 'invalid lat/lng')
  end

  def test_invalid_parameter
    mine = lookup
    mine.client.body = File.open(mock_path + '/invalid_parameter.json').read

    assert_exception(mine, 'error parsing parameter')
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
