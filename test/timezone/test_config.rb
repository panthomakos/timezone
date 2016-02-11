require 'timezone/config'
require 'minitest/autorun'

class TestConfig < ::Minitest::Test
  def test_test_config
    Timezone::Config.config(:test)

    assert_equal Timezone::Lookup::Test,
      Timezone::Config.lookup.class
  end

  def test_geonames_config
    Timezone::Config.config(:geonames) do |c|
      c.username = 'foo'
    end

    assert_equal Timezone::Lookup::Geonames,
      Timezone::Config.lookup.class

    assert_equal Timezone::NetHTTPClient,
      Timezone::Config.lookup.config.http_client
  end

  def test_google_config
    Timezone::Config.config(:google) do |c|
      c.api_key = 'foo'
    end

    assert_equal Timezone::Lookup::Google,
      Timezone::Config.lookup.class

    assert_equal Timezone::NetHTTPClient,
      Timezone::Config.lookup.config.http_client
  end

  def test_custom_config
    custom_lookup = Class.new do
      def initialize(config) ; end
    end

    Timezone::Config.config(custom_lookup)

    assert_equal custom_lookup, Timezone::Config.lookup.class
  end

  def test_missing_config
    Timezone::Config.instance_variable_set(:@lookup, nil)

    assert_raises Timezone::Error::InvalidConfig do
      Timezone::Config.lookup
    end
  end
end
