# frozen_string_literal: true

require 'timezone/lookup/geonames'
require 'minitest/autorun'
require 'ostruct'
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

  def lookup_file(file_name, &block)
    lookup(File.open(File.join(mock_path, file_name)).read, &block)
  end

  def lookup(body = nil, &_block)
    config = OpenStruct.new
    config.username = 'timezone'
    config.request_handler = HTTPTestClientFactory.new(body)
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
    mine = lookup_file('/lat_lon_coords.txt')

    assert_equal 'Australia/Adelaide', mine.lookup(*coordinates)
  end

  def test_lookup_with_etc
    etc_data.each do |key, data|
      mine = lookup_file("/lat_lon_coords_#{key}.txt") do |c|
        c.offset_etc_zones = true
      end

      assert_equal data[:name], mine.lookup(*data[:coordinates])
    end
  end

  def test_wrong_offset
    mine = lookup_file('/lat_lon_coords_wrong_offset.txt') do |c|
      c.offset_etc_zones = true
    end

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
    mine = lookup_file('/api_limit_reached.json')

    assert_exception(
      mine,
      'the daily limit of 30000 credits for XXXXX has been exceeded. ' \
        'Please throttle your requests or use the commercial service.'
    )
  end

  def test_invalid_latlong
    mine = lookup_file('/invalid_latlong.json')

    assert_exception(mine, 'invalid lat/lng')
  end

  def test_no_result_found
    mine = lookup_file('/no_result_found.json')

    assert_nil(mine.lookup(10, 10))
  end

  def test_invalid_parameter
    mine = lookup_file('/invalid_parameter.json')

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
