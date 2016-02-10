require 'timezone/zone'
require 'minitest/autorun'

class TestZone < ::Minitest::Test
  parallelize_me!

  def la
    @la ||= Timezone::Zone.new(zone: 'America/Los_Angeles')
  end

  def paris
    @paris ||= Timezone::Zone.new(zone: 'Europe/Paris')
  end

  def test_to_s
    assert_equal('America/Los_Angeles', la.to_s)
    assert_equal('Europe/Paris', paris.to_s)
  end

  def test_inspect
    assert_equal(
      '#<Timezone::Zone zone: "America/Los_Angeles", rules: [...]>',
      la.inspect
    )

    assert_equal(
      '#<Timezone::Zone zone: "Europe/Paris", rules: [...]>',
      paris.inspect
    )
  end
end
