# frozen_string_literal: true

require 'timezone/nil_zone'
require 'minitest/autorun'

class TestNilZone < ::Minitest::Test
  parallelize_me!

  def setup
    @zone = Timezone::NilZone.new
  end

  def test_name
    assert_nil @zone.name
  end

  def test_to_s
    assert_equal 'NilZone', @zone.to_s
  end

  def test_inspect
    assert '#<Timezone::NilZone>', @zone.inspect
  end

  def test_valid?
    refute @zone.valid?
  end
end
