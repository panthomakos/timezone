require 'timezone/rule'

module Timezone
  @@zone_name = ''

  # Given a string of TZDATA, generate a collection of Entry objects.
  def self.entries(data)
    data.split("\n").map{ |line| entry(line) }
  end

  # Each entry follows this format.
  # GMT-OFFSET RULES FORMAT [UNTIL]
  ENTRY = /(\d+?:\d+?:*\d*?)\s+(.+?)\s([^\s]+)\s*(.*?)$/

  # The header entry also includes the Zone name.
  # Zone ZONE-NAME GMT-OFFSET RULES FORMAT [UNTIL]
  HEADER = /Zone\s+(.+?)\s+/

  # Given a line from the TZDATA file, generate an Entry object.
  def self.entry(line)
    @@zone_name = $~[1] if line.match(HEADER)

    Entry.new(@@zone_name, *line.match(ENTRY)[1..-1].map(&:strip))
  end

  Entry = Struct.new(:name, :offset, :rule, :format, :until) do
    def rules
      Timezone.rules[rule]
    end
  end
end
