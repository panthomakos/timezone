# frozen_string_literal: true

require 'timezone'
require 'minitest/autorun'

class TestTimezone < ::Minitest::Test
  parallelize_me!

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
    assert_equal 'foo', Timezone.fetch('foo/bar', 'foo')

    Timezone.stub(:warn, nil) do
      assert_equal 'b', Timezone.fetch('foo/bar', 'a') { 'b' }
    end
  end

  def test_fetch_warning
    warning = false

    Timezone.stub(:warn, ->(_) { warning = true }) do
      Timezone.fetch('foo/bar', 'a') { 'b' }
    end

    assert warning, 'warning was not issued'
  end

  def test_lookup
    Timezone::Lookup.config(:test)

    Timezone::Lookup.lookup.stub(-10, 10, 'America/Los_Angeles')
    Timezone::Lookup.lookup.stub(-20, 20, 'foos')

    assert_equal Timezone['America/Los_Angeles'], Timezone.lookup(-10, 10)
    assert_equal 'foo', Timezone.lookup(-20, 20) { 'foo' }
    assert_raises Timezone::Error::InvalidZone do
      Timezone.lookup(-20, 20)
    end
    assert_equal 'foo', Timezone.lookup(-20, 20, 'foo')

    Timezone.stub(:warn, nil) do
      assert_equal 'b', Timezone.lookup(-20, 20, 'a') { 'b' }
    end
  end
end
