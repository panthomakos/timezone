require 'timezone/parser/zone'
require 'minitest/autorun'

describe Timezone::Parser::Zone do
  def setup
    @zones = []
    @zones << Timezone::Parser.zone('Zone	Asia/Hebron	2:20:23	-	LMT	1900 Oct')
    @zones << Timezone::Parser.zone('2:00	Zion	EET	1948 May 15')
    @zones << Timezone::Parser.zone('2:00 EgyptAsia	EE%sT	1967 Jun  5')
  end

  it 'properly parses zone names' do
    assert @zones.all?{ |e| e.name == 'Asia/Hebron' }
  end
end
