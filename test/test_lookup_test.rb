require 'timezone/configure'
require 'timezone/lookup/test'
require 'timezone/zone'
require 'minitest/autorun'

class TestLookupTest < ::Minitest::Unit::TestCase
  def setup
    Timezone::Configure.begin do |c|
      c.lookup = ::Timezone::Lookup::Test
    end
  end

  def test_simple_stub
    ::Timezone::Configure.lookup.stub(-10, 10, 'America/Los_Angeles')

    assert_equal(
      'America/Los_Angeles',
      ::Timezone::Zone.new(lat: -10, lon: 10).zone)
  end

  def test_missing_stub
    assert_raises(::Timezone::Error::Test) do
      ::Timezone::Zone.new(lat: 100, lon: 100)
    end
  end

  def test_clear_lookup
    ::Timezone::Configure.begin do |c|
      c.username = 'foo'
      c.lookup = nil
    end

    assert ::Timezone::Lookup::Geonames, ::Timezone::Configure.lookup.class
  end

  def teardown
    Timezone::Configure.begin { |c| c.lookup = nil }
  end
end
