require 'time'

module Timezone
  module Parser
    # Given a line from the TZDATA file, generate an Entry object.
    def self.zone(line) ; Zone.generate(line) ; end

    # Given a string of TZDATA, generate a collection of Entry objects.
    def self.zones(data)
      data.split("\n").map{ |line| zone(line) }
    end

    module Zone
      # Each entry follows this format.
      # GMT-OFFSET RULES FORMAT [UNTIL]
      ENTRY = /(\d+?:\d+?:*\d*?)\s+(.+?)\s([^\s]+)\s*(.*?)$/

      # The header entry also includes the Zone name.
      # Zone ZONE-NAME GMT-OFFSET RULES FORMAT [UNTIL]
      HEADER = /Zone\s+(.+?)\s+/

      # Name of the current zone entry (parsed from the header).
      @@zone_name = ''

      class << self
        def generate(line)
          @@zone_name = $~[1] if line.match(HEADER)

          Entry.new(@@zone_name, *line.match(ENTRY)[1..-1])
        end
      end
    end
  end
end

require 'timezone/parser/zone/entry'
