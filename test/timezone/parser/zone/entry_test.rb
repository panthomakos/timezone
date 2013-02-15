require 'timezone/parser/zone/entry'
require 'minitest/autorun'

describe Timezone::Parser::Zone::Entry do
  def setup
    Timezone::Parser.rules.clear
    # This first rule is before the end date.
    Timezone::Parser.rule("Rule	Zion	1870	only	-	Jan	13	0:00	0:00	D")
    # This second rule is after the end date.
    Timezone::Parser.rule("Rule	Zion	1901	only	-	Oct	12	0:00	0:00	D")

    @zone = Timezone::Parser::Zone::Entry.new(
      'Asia/Hebron', '2:00', 'Zion', 'EET', '1900 Oct')
  end

  it 'properly parses offsets' do
    assert_equal 7_200, @zone.offset
  end

  it 'properly selects rules based on a timeline' do
    assert_equal 1, @zone.rules.count
  end

  it 'properly parses format' do
    assert_equal 'EET', @zone.format
  end

  it 'properly parses end_date' do
    assert_equal Time.utc(1900, 10, 1, 0, 0, 0).to_i * 1_000, @zone.end_date
  end
end
