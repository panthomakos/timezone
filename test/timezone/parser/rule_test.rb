require 'timezone/parser/rule'
require 'minitest/autorun'

describe Timezone::Parser::Rule do
  before do
    Timezone::Parser.rules.clear
    @rule = Timezone::Parser.rule("Rule	Zion	1940	only	-	Jun	 1	0:00	1:00	D")
    @oddity = Timezone::Parser.rule("Rule	Zion	1948	1950	-	May	23	0:00	2:20	S")
  end

  it 'adds multiple rules with the same name' do
    assert_equal 2, Timezone::Parser.rules['Zion'].count
  end

  describe '#offset' do
    it 'properly calculates hours' do
      assert_equal 3_600, @rule.offset
    end

    it 'properly calculates minutes' do
      assert_equal 8_400, @oddity.offset
    end
  end

  describe '#dst?' do
    it 'knows standard time' do
      assert !@oddity.dst?
    end

    it 'knows daylight savings time' do
      assert @rule.dst?
    end
  end

  it 'properly calculates start_date' do
    assert_equal Time.utc(1940, 6, 1, 0, 0, 0).to_i*1_000, @rule.start_date
  end

  it 'properly calculates years' do
    assert_equal [1940], @rule.years
    assert_equal [1948, 1949, 1950], @oddity.years
  end
end
