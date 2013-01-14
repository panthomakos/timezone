require 'timezone/rule'
require 'minitest/autorun'

describe Timezone::Rule do
  before{ Timezone.rules.clear }

  def setup
    @rule = Timezone::Rule.new('Zion')
  end

  it 'adds itself to the rules' do
    assert_empty Timezone.rules
    Timezone::Rule.new('Zion')
    assert_equal ['Zion'], Timezone.rules.keys
  end

  it 'adds multiple rules' do
    2.times{ Timezone::Rule.new('Zion') }
    assert_equal 2, Timezone.rules['Zion'].count
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
end
