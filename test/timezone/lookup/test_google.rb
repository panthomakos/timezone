require 'timezone/lookup/google'
require 'minitest/autorun'
require 'timecop'
require_relative '../../http_test_client'

class TestGoogle < ::Minitest::Test
  parallelize_me!

  def coordinates
    [-34.92771808058, 138.477041423321]
  end

  def config
    config = OpenStruct.new
    config.http_client = HTTPTestClient
    config.api_key = 'MTIzYWJj'
    config
  end

  def lookup
    Timezone::Lookup::Google.new(config)
  end

  def test_default_config
    assert_equal 'https', lookup.config.protocol
    assert_equal 'maps.googleapis.com', lookup.config.url
  end

  def test_missing_api_key
    assert_raises(::Timezone::Error::InvalidConfig) do
      Timezone::Lookup::Google.new(OpenStruct.new)
    end
  end

  def test_google_using_lat_long_coordinates
    mine = lookup
    mine.client.body = File.open(mock_path + '/google_lat_lon_coords.txt').read

    assert_equal 'Australia/Adelaide', mine.lookup(*coordinates)
  end

  def test_google_request_denied_read_lat_long_coordinates
    mine = lookup
    mine.client.body = nil
    assert_raises Timezone::Error::Google, 'The provided API key is invalid.' do
      mine.lookup(*coordinates)
    end
  end

  def test_url_non_enterprise
    Timecop.freeze(Time.at(1433347661)) do
      result = lookup.send(:url, '123', '123')
      params = {
        'location' => '123%2C123',
        'timestamp' => '1433347661',
        'key' => 'MTIzYWJj'
      }.map { |k,v| "#{k}=#{v}" }

      assert_equal "/maps/api/timezone/json?#{params.join('&')}", result
    end
  end

  def test_url_enterprise
    econfig = config
    econfig.client_id = '123&asdf'

    enterprise = Timezone::Lookup::Google.new(econfig)

    Timecop.freeze(Time.at(1433347661)) do
      result = enterprise.send(:url, '123', '123')
      params = {
        'location' => '123%2C123',
        'timestamp' => '1433347661',
        'client' => '123%26asdf',
        'signature' => 'B1TNSSvIw9Wvf_ZjjW5uRzGm4F4='
      }.map { |k,v| "#{k}=#{v}" }

      assert_equal "/maps/api/timezone/json?#{params.join('&')}", result
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
