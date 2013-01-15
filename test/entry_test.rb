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
    assert_equal '2:20:23', @entries.first.offset
    assert @entries[1..-1].all?{ |e| e.offset == '2:00' }
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

  it 'properly parses until' do
    assert '1900 Oct', @entries.first.until
    assert '', @entries.last.until
  end
end
