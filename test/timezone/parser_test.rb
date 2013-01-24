require 'timezone/parser'
require 'minitest/autorun'

describe Timezone::Parser do
  it 'parses files with no errors' do
    Timezone::Parser.parse('test/data/asia')
  end
end
