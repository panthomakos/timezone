# frozen_string_literal: true

require 'timezone/lookup'
require 'minitest/autorun'

class TestLookup < ::Minitest::Test
  def test_test_config
    Timezone::Lookup.config(:test)

    assert_equal Timezone::Lookup::Test,
      Timezone::Lookup.lookup.class
  end

  def test_geonames_config
    Timezone::Lookup.config(:geonames) do |c|
      c.username = 'foo'
    end

    assert_equal Timezone::Lookup::Geonames,
      Timezone::Lookup.lookup.class

    assert_equal Timezone::NetHTTPClient,
      Timezone::Lookup.lookup.config.request_handler
  end

  def test_google_config
    Timezone::Lookup.config(:google) do |c|
      c.api_key = 'foo'
    end

    assert_equal Timezone::Lookup::Google,
      Timezone::Lookup.lookup.class

    assert_equal Timezone::NetHTTPClient,
      Timezone::Lookup.lookup.config.request_handler
  end

  def test_custom_config
    custom_lookup = Class.new do
      def initialize(config); end
    end

    Timezone::Lookup.config(custom_lookup)

    assert_equal custom_lookup, Timezone::Lookup.lookup.class
  end

  def test_missing_config
    Timezone::Lookup.instance_variable_set(:@lookup, nil)

    assert_raises Timezone::Error::InvalidConfig do
      Timezone::Lookup.lookup
    end
  end
end
