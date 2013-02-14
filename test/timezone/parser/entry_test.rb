require 'timezone/parser/entry'
require 'minitest/autorun'

describe Timezone::Parser::Entry do
  HEBRON = <<-HEBRON
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
  HEBRON

  def setup
    @entries = Timezone::Parser.entries(HEBRON)
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
    Timezone::Parser.rule("Rule	Zion	1948	only	-	Jan	13	0:00	0:00	D")
    # This second rule is after the end date.
    Timezone::Parser.rule("Rule	Zion	1967	only	-	Oct	12	0:00	0:00	D")

    assert_equal 1, @entries[1].rules.count
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

  it 'properly applies Zion rules' do
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
    rules = @entries[0].data(rules, nil)
    rules = @entries[1].data(rules, @entries[0].end_date)
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

  describe 'Nicosia' do
    NICOSIA = <<-NICOSIA
Zone	Asia/Nicosia	2:13:28 -	LMT	1921 Nov 14
			2:00	Cyprus	EE%sT	1998 Sep
			2:00	EUAsia	EE%sT
    NICOSIA

    def setup
      @nicosia = Timezone::Parser.entries(NICOSIA)
      Timezone::Parser.rules.clear
    end

    it 'properly parses' do
      Timezone::Parser.rule("Rule	Cyprus	1975	only	-	Apr	13	0:00	1:00	S")
      Timezone::Parser.rule("Rule	Cyprus	1975	only	-	Oct	12	0:00	0	-")
      Timezone::Parser.rule("Rule	Cyprus	1976	only	-	May	15	0:00	1:00	S")
      Timezone::Parser.rule("Rule	Cyprus	1976	only	-	Oct	11	0:00	0	-")
      Timezone::Parser.rule("Rule	Cyprus	1977	1980	-	Apr	Sun>=1	0:00	1:00	S")
      Timezone::Parser.rule("Rule	Cyprus	1977	only	-	Sep	25	0:00	0	-")
      Timezone::Parser.rule("Rule	Cyprus	1978	only	-	Oct	2	0:00	0	-")
      Timezone::Parser.rule("Rule	Cyprus	1979	1997	-	Sep	lastSun	0:00	0	-")
      Timezone::Parser.rule("Rule	Cyprus	1981	1998	-	Mar	lastSun	0:00	1:00	S")
      Timezone::Parser.rule("Rule	EUAsia	1981	max	-	Mar	lastSun	 1:00u	1:00	S")
      Timezone::Parser.rule("Rule	EUAsia	1979	1995	-	Sep	lastSun	 1:00u	0	-")
      Timezone::Parser.rule("Rule	EUAsia	1996	max	-	Oct	lastSun	 1:00u	0	-")

      rules = []
      rules = @nicosia[0].data(rules, nil)
      rules = @nicosia[1].data(rules, @nicosia[0].end_date)
      rules = @nicosia[2].data(rules, @nicosia[1].end_date)
      Timezone::Parser.normalize!(rules)

      assert rules[-2].dst
      assert_equal 10_800, rules[-2].offset
      assert_equal 2531955600000, rules[-2].start_date
      assert_equal 2550704400000, rules[-2].end_date
      assert_equal 'EEST', rules[-2].name

      assert !rules.last.dst
      assert_equal 7_200, rules.last.offset
      assert_equal 2550704400000, rules.last.start_date
      assert_equal 253402300799000, rules.last.end_date
      assert_equal 'EET', rules.last.name

      assert_equal 154, rules.count
    end
  end
end
