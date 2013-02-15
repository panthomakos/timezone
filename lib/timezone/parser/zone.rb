require 'time'

module Timezone
  module Parser
    # Given a line from the TZDATA file, generate an Entry object.
    def self.zone(line) ; Zone.parse(line) ; end

    # Get a list of all processed entries.
    def self.zones ; Zone.zones ; end

    module Zone
      # Each entry follows this format.
      # GMT-OFFSET RULES FORMAT [UNTIL]
      ENTRY = /(\d+?:\d+?:*\d*?)\s+(.+?)\s([^\s]+)\s*(.*?)$/

      # The header entry also includes the Zone name.
      # Zone ZONE-NAME GMT-OFFSET RULES FORMAT [UNTIL]
      HEADER = /Zone\s+(.+?)\s+/

      # Zones are stored in a hash of arrays that are referenced by name.
      @@zones = Hash.new{ |h, k| h[k] = [] }
      def self.zones ; @@zones ; end

      # The name of the current zone is parsed from the header zone entry.
      # It can then be accessed using `Timezone::Parser::Zone.last`.
      class << self ; attr_accessor :last ; end

      def self.parse(line)
        self.last = $~[1] if line.match(HEADER)

        @@zones[last] << Entry.new(last, *line.match(ENTRY)[1..-1])
      end
    end
  end
end

require 'timezone/parser/zone/entry'
