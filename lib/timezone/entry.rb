require 'timezone/rule'

module Timezone
  @@zone_name = ''

  def self.entries(lines)
    lines.split("\n").map{ |line| entry(line) }
  end

  ENTRY = /(\d+?:\d+?:*\d*?)\s+(.+?)\s([^\s]+)\s*(.*?)$/
  FIRST = /Zone\s+(.+?)\s+/

  def self.entry(line)
    if line.match(FIRST)
      @@zone_name = $~[1]
    end

    match = line.match(ENTRY)

    Entry.new(@@zone_name, *match[1..-1].map(&:strip))
  end

  Entry = Struct.new(:name, :offset, :rule, :format, :until) do
    def rules
      Timezone.rules[rule]
    end
  end
end
