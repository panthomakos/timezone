require 'timezone'
require 'minitest/autorun'

class TestTimezone < ::Minitest::Test
  parallelize_me!

  def setup
    Timezone::Config.config(:test)
  end

  def test_names
    assert Timezone.names.is_a?(Array)
    refute Timezone.names.empty?
    assert Timezone.names.include?('Australia/Sydney')
    assert Timezone.names.include?('America/Los_Angeles')
  end

  def test_get
    assert Timezone['Australia/Sydney'].valid?
    refute Timezone['foo/bar'].valid?
  end

  def test_fetch
    assert Timezone.fetch('Australia/Sydney').valid?
    assert_equal 'foo', Timezone.fetch('foo/bar') { 'foo' }
    assert_raises Timezone::Error::InvalidZone do
      Timezone.fetch('foo/bar')
    end
  end

  def test_lookup
    Timezone::Config.lookup.stub(-10, 10, 'America/Los_Angeles')

    assert_equal Timezone.lookup(-10, 10), Timezone['America/Los_Angeles']
  end
end
