require 'timezone/parser/zone/until'
require 'minitest/autorun'

describe Timezone::Parser::Zone::Until do
  def parse(*args)
    Timezone::Parser::Zone::Until.parse(*args)
  end

  it 'parses dates' do
    assert_equal -2185401600000, parse('1900 Oct')
    assert_equal -682646400000, parse('1948 May 15')
  end
end
