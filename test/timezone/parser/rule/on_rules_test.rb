require 'timezone/parser/rule/on_rules'
require 'minitest/autorun'

describe Timezone::Parser::Rule::On do
  def parse(*args)
    Timezone::Parser::Rule::On.parse(*args)
  end

  it 'parses lastDAY' do
    assert_equal ['Oct', '29'], parse('lastSun', 'Oct', 1995)
    assert_equal ['Oct', '27'], parse('lastSun', 'Oct', 1996)
    assert_equal ['Oct', '26'], parse('lastSun', 'Oct', 1997)
  end

  it 'parses DAY>=NUM' do
    assert_equal ['Apr', '01'], parse('Fri>=26', 'Mar', 2005)
    assert_equal ['Mar', '31'], parse('Fri>=26', 'Mar', 2006)
    assert_equal ['Mar', '30'], parse('Fri>=26', 'Mar', 2007)
  end
end
