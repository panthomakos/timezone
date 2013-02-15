require 'timezone/parser'
require 'minitest/autorun'

describe Timezone::Parser do
  it 'parses files with no errors' do
    Timezone::Parser.parse('test/data/asia')
    # File.open('data/Asia/Hebron.json', 'w') do |f|
    #   hash = { '_zone' => 'Asia/Hebron', 'zone' => Timezone::Parser::Zone.data['Asia/Hebron'].map(&:to_hash) }
    #   f.puts(JSON.pretty_generate(hash))
    # end
  end
end
