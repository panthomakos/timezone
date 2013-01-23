require 'timezone/parser'
require 'minitest/autorun'

describe Timezone::Parser do
  it 'parses files' do
    # TODO Eventually this should parse the entire asia file
    # without errors. Right now there are many rule formats
    # that are not supported.

    # Timezone::Parser.parse('test/data/asia')
  end
end
