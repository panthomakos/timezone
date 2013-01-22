require 'timezone/parser/rule'
require 'minitest/autorun'

describe Timezone::Parser::Rule do
  before do
    Timezone::Parser.rules.clear
    @rule = Timezone::Parser::Rule.new('Zion')
  end

  it 'adds itself to the rules' do
    assert_equal ['Zion'], Timezone::Parser.rules.keys
  end

  it 'adds multiple rules with the same name' do
    Timezone::Parser::Rule.new('Zion')
    assert_equal 2, Timezone::Parser.rules['Zion'].count
  end

  describe '#offset' do
    it 'properly calculates hours' do
      @rule.save = '1:00'
      assert_equal 3_600, @rule.offset
    end

    it 'properly calculates minutes' do
      @rule.save = '2:20'
      assert_equal 8_400, @rule.offset
    end
  end

  describe '#dst?' do
    it 'knows standard time' do
      @rule.letter = 'S'
      assert !@rule.dst?
    end

    it 'knows daylight savings time' do
      @rule.letter = 'D'
      assert @rule.dst?
    end
  end

  it 'properly parses TZDATA rules' do
    rule = Timezone::Parser.rule("Rule	Zion	1940	only	-	Jun	 1	0:00	1:00	D")

    assert_instance_of Timezon::Parsere::Rule, rule
    assert_equal 'Zion', rule.name
    assert_equal '1940', rule.from
    assert_equal 'only', rule.to
    assert_equal 'Jun', rule.month
    assert_equal '1', rule.day
    assert_equal '1:00', rule.save
    assert_equal 'D', rule.letter
  end
end
