require 'timezone/parser/entry'
require 'minitest/autorun'

describe Timezone::Parser::Entry do
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
    @entries = Timezone::Parser.entries(LINES)
    Timezone::Parser.rules.clear
  end

  it 'properly parses entry names' do
    assert @entries.all?{ |e| e.name == 'Asia/Hebron' }
  end

  it 'properly parses offsets' do
    assert_equal 8423, @entries.first.offset
    assert @entries[1..-1].all?{ |e| e.offset == 7200 }
  end

  it 'properly selects rules based on a timeline' do
    # Empty rule set.
    assert_empty @entries[0].rules

    # This first rule is before the end date.
    r1 = Timezone::Parser::Rule.new('Zion', '1948', 'only', '', 'Jan', '13', '0:00', '0', 'D')
    # This second rule is after the end date.
    r2 = Timezone::Parser::Rule.new('Zion', '1967', 'only', '', 'Oct', '12', '0:00', '0', 'D')

    assert_equal [r1], @entries[1].rules
  end

  it 'properly parses format' do
    assert_equal 'LMT', @entries[0].format
    assert_equal 'EET', @entries[1].format
    assert_equal 'EE%sT', @entries[2].format
  end

  it 'properly parses end_date' do
    assert_equal Time.utc(1900, 10, 1, 0, 0, 0).to_i * 1_000, @entries.first.end_date
    assert_equal nil, @entries.last.end_date
  end

  it 'properly applies' do
    Timezone::Parser.rule("Rule	Zion	1940	only	-	Jun	 1	0:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1942	1944	-	Nov	 1	0:00	0	S")
    Timezone::Parser.rule("Rule	Zion	1943	only	-	Apr	 1	2:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1944	only	-	Apr	 1	0:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1945	only	-	Apr	16	0:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1945	only	-	Nov	 1	2:00	0	S")
    Timezone::Parser.rule("Rule	Zion	1946	only	-	Apr	16	2:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1946	only	-	Nov	 1	0:00	0	S")
    Timezone::Parser.rule("Rule	Zion	1948	only	-	May	23	0:00	2:00	DD")
    Timezone::Parser.rule("Rule	Zion	1948	only	-	Sep	 1	0:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1948	1949	-	Nov	 1	2:00	0	S")
    Timezone::Parser.rule("Rule	Zion	1949	only	-	May	 1	0:00	1:00	D")

    rules = []
    rules.concat(@entries[0].data)
    rules.concat(@entries[1].data(rules.first.end_date))
    Timezone::Parser.normalize!(rules)

    assert_equal 12, rules.count

    assert_equal Timezone::Parser::START_DATE, rules[0].start_date
    assert_equal -2185410023000, rules[0].end_date
    assert !rules[0].dst
    assert_equal 8423, rules[0].offset
    assert_equal 'LMT', rules[0].name

    assert_equal "-9999-01-01T00:00:00Z", JSON.parse(rules[0].to_json)['_from']
    assert_equal "1900-09-30T21:39:37Z", JSON.parse(rules[0].to_json)['_to']

    assert_equal -2185410023000, rules[1].start_date
    assert_equal -933645600000, rules[1].end_date
    assert !rules[1].dst
    assert_equal 7_200, rules[1].offset
    assert_equal 'EET', rules[1].name

    assert_equal -933645600000, rules[2].start_date
    assert_equal -857358000000, rules[2].end_date
    assert rules[2].dst
    assert_equal 10_800, rules[2].offset
    assert_equal 'EET', rules[2].name

    assert_equal -857358000000, rules[3].start_date
    assert_equal -844300800000, rules[3].end_date
    assert !rules[3].dst
    assert_equal 7_200, rules[3].offset
    assert_equal 'EET', rules[3].name

    assert_equal -844300800000, rules[4].start_date
    assert_equal -825822000000, rules[4].end_date
    assert rules[4].dst
    assert_equal 10_800, rules[4].offset
    assert_equal 'EET', rules[4].name
  end
end
