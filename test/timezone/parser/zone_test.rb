require 'timezone/parser/zone'
require 'minitest/autorun'

describe Timezone::Parser::Zone do
  def setup
    Timezone::Parser.rules.clear
    Timezone::Parser.zones.clear
    # This first rule is before the end date.
    Timezone::Parser.rule("Rule	Zion	1948	only	-	Jan	13	0:00	0:00	D")
    # This second rule is after the end date.
    Timezone::Parser.rule("Rule	Zion	1949	only	-	Oct	12	0:00	0:00	D")

    Timezone::Parser.zone('Zone	Asia/Hebron	2:20:23	-	LMT	1900 Oct')
    Timezone::Parser.zone('2:00	Zion	EET	1948 May 15')
    Timezone::Parser.zone('2:00 EgyptAsia	EE%sT	1967 Jun  5')

    @zones = Timezone::Parser.zones['Asia/Hebron']
  end

  it 'properly parses all zone names' do
    assert_equal 3, Timezone::Parser.zones['Asia/Hebron'].count
    assert Timezone::Parser.zones['Asia/Hebron'].all?{ |z| z.name == 'Asia/Hebron' }
  end

  it 'parses offset' do
    assert_equal [8423, 7_200, 7_200], @zones.map(&:offset)
  end

  it 'only selects rules within the entry timeline' do
    assert_equal 1, @zones[1].rules.count
  end

  it 'parses format' do
    assert_equal ['LMT', 'EET', 'EE%sT'], @zones.map(&:format)
  end

  it 'parses end_date' do
    assert_equal Time.utc(1900, 10,  1).to_i * 1_000, @zones[0].end_date
    assert_equal Time.utc(1948,  5, 15).to_i * 1_000, @zones[1].end_date
    assert_equal Time.utc(1967,  6,  5).to_i * 1_000, @zones[2].end_date
  end
end
