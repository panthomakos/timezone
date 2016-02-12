require 'timezone/configure'
require 'timezone/lookup/google'
require 'minitest/autorun'
require 'timecop'
require_relative 'http_test_client'

class GoogleLookupTest < ::Minitest::Unit::TestCase
  def setup
    config { |c| c.google_api_key = 'MTIzYWJj' }
  end

  def coordinates
    [-34.92771808058, 138.477041423321]
  end

  def lookup
    ::Timezone::Configure.lookup
  end

  def config(&block)
    Timezone::Configure.instance_variable_set(:@lookup, nil)
    Timezone::Configure.instance_variable_set(:@geonames_lookup, nil)
    Timezone::Configure.instance_variable_set(:@google_lookup, nil)

    Timezone::Configure.begin do |c|
      c.http_client = HTTPTestClient
      block.call(c)
    end
  end

  def test_google_using_lat_lon_coordinates
    lookup.client.body =
      File.open(mock_path + '/google_lat_lon_coords.txt').read

    assert_equal 'Australia/Adelaide', lookup.lookup(*coordinates)
  end

  def test_google_request_denied_read_lat_lon_coordinates
    lookup.client.body = nil
    assert_raises Timezone::Error::Google do
      lookup.lookup(*coordinates)
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
    config { |c| c.google_client_id = '123&asdf' }

    Timecop.freeze(Time.at(1433347661)) do
      result = lookup.send(:url, '123', '123')
      params = {
        'location' => '123%2C123',
        'timestamp' => '1433347661',
        'client' => '123%26asdf',
        'signature' => 'B1TNSSvIw9Wvf_ZjjW5uRzGm4F4='
      }.map { |k,v| "#{k}=#{v}" }

      assert_equal "/maps/api/timezone/json?#{params.join('&')}", result
    end
  ensure
    config { |c| c.google_client_id = nil }
  end

  private

  def mock_path
    File.expand_path(File.join(File.dirname(__FILE__), 'mocks'))
  end
end
