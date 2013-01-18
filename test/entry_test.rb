require 'timezone/entry'
require 'minitest/autorun'

describe Timezone::Entry do
  LINES = <<-LINES
Zone	Asia/Hebron	2:20:23	-	LMT	1900 Oct
      2:00	Zion	EET	1948 May 15
      2:00 EgyptAsia	EE%sT	1967 Jun  5
      2:00	Zion	I%sT	1996
      2:00	Jordan	EE%sT	1999
      2:00 Palestine	EE%sT	2008 Aug
      2:00 	1:00	EEST	2008 Sep
      2:00 Palestine	EE%sT	2011 Apr  1 12:01
      2:00	1:00	EEST	2011 Aug  1
      2:00	-	EET	2011 Aug 30
      2:00	1:00	EEST	2011 Sep 30 3:00
      2:00	-	EET	2012 Mar 30
      2:00	1:00	EEST	2012 Sep 21 1:00
      2:00	-	EET
  LINES

  def setup
    @entries = Timezone.entries(LINES)
  end

  it 'properly parses entry names' do
    assert @entries.all?{ |e| e.name == 'Asia/Hebron' }
  end

  it 'properly parses offsets' do
    assert_equal 8423, @entries.first.offset
    assert @entries[1..-1].all?{ |e| e.offset == 7200 }
  end

  it 'proplery parses rules' do
    Timezone::Rule.new('Zion')
    Timezone::Rule.new('Palestine')
    assert_equal Timezone.rules['Zion'], @entries[1].rules
    assert_equal Timezone.rules['Palestine'], @entries[5].rules
  end

  it 'properly parses format' do
    assert_equal 'LMT', @entries[0].format
    assert_equal 'EET', @entries[1].format
    assert_equal 'EE%sT', @entries[2].format
  end

  it 'properly parses end_date' do
    assert_equal -2185410023000, @entries.first.end_date
    assert_equal nil, @entries.last.end_date
  end

  it 'properly applies' do
    first = @entries[0].data.first

    assert_equal Timezone::START_DATE, first.from
    assert_equal Timezone::END_DATE, first.to
    assert_equal false, first.dst
    assert_equal 8423, first.offset
    assert_equal 'LMT', first.name
  end
end
