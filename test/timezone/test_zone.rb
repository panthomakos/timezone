require 'timezone/zone'
require 'minitest/autorun'

class TestZone < ::Minitest::Test
  parallelize_me!

  def la
    @la ||= Timezone::Zone.new('America/Los_Angeles')
  end

  def paris
    @paris ||= Timezone::Zone.new('Europe/Paris')
  end

  def test_name
    assert_equal 'America/Los_Angeles', la.name
    assert_equal 'Europe/Paris', paris.name
  end

  def test_valid?
    assert la.valid?
    assert paris.valid?
  end

  def test_to_s
    assert_equal 'America/Los_Angeles', la.to_s
    assert_equal 'Europe/Paris', paris.to_s
  end

  def test_inspect
    assert_equal(
      '#<Timezone::Zone name: "America/Los_Angeles">',
      la.inspect
    )

    assert_equal(
      '#<Timezone::Zone name: "Europe/Paris">',
      paris.inspect
    )
  end

  def test_comparable
    assert paris > la
    assert la < paris
    assert la == Timezone::Zone.new('America/Los_Angeles')

    assert_equal nil, paris <=> 8
  end
end
