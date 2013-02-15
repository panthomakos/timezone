require 'timezone/parser/rule'
require 'minitest/autorun'

describe Timezone::Parser::Rule do
  before do
    Timezone::Parser.rules.clear
    Timezone::Parser.rule("Rule	Zion	1940	only	-	Jun	 1	0:00	1:00	D")
    @rule = Timezone::Parser.rules['Zion'].first
    Timezone::Parser.rule("Rule	Zion	1948	1950	-	May	23	0:00	2:20	S")
    @oddity = Timezone::Parser.rules['Zion'].last
  end

  it 'adds multiple rules with the same name' do
    assert_equal 4, Timezone::Parser.rules['Zion'].count
  end

  describe '#offset' do
    it 'properly calculates hours' do
      assert_equal 3_600, @rule.offset
    end

    it 'properly calculates minutes' do
      assert_equal 8_400, @oddity.offset
    end
  end

  it 'selects rules given an end date' do
    end_date = Time.new(1947, 1, 1).to_i * 1_000
    assert_equal [@rule], Timezone::Parser.select_rules('Zion', end_date)
  end

  it 'knows daylight savings time' do
    assert @rule.dst?
  end

  it 'properly calculates start_date' do
    assert_equal Time.utc(1940, 6, 1, 0, 0, 0).to_i*1_000, @rule.start_date
  end

  it 'understands lastDAY rules' do
    Timezone::Parser.rule("Rule	EUAsia	1996	max	-	Oct	lastSun	 1:00u	0	-")
    rule = Timezone::Parser.rules['EUAsia'].first

    assert_equal Time.utc(1996, 10, 27, 1, 0, 0).to_i*1_000, rule.start_date
  end

  it 'understands DAY>=NUM rules' do
    Timezone::Parser.rule("Rule	Zion	2005	only	-	Mar	Fri>=26	2:00	1:00	D")
    rule = Timezone::Parser.rules['Zion'].last
    assert_equal Time.utc(2005, 4, 1, 2, 0, 0).to_i*1_000, rule.start_date
  end
end
