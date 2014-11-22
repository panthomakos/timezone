require 'time'

module Timezone
  module Parser
    # Given a line from the TZDATA file, generate an Entry object.
    def self.zone(line) ; Zone.parse(line) ; end

    # Get a list of all processed entries.
    def self.zones ; Zone.zones ; end

    module Zone
      # HH:MM:SS Entries follow this format.
      # GMT-OFFSET RULES FORMAT [UNTIL]

      # +/- HH Entries follow this format
      # GMT-OFFSET RULES [FORMAT] [UNTIL]

      # The header entry also includes the Zone name.
      # Zone ZONE-NAME GMT-OFFSET RULES FORMAT [UNTIL]
      HEADER = /^\s*Zone\s+(.+?)\s+/

      # Zones are stored in a hash of arrays that are referenced by name.
      @@zones = Hash.new{ |h, k| h[k] = [] }
      def self.zones ; @@zones ; end

      # The name of the current zone is parsed from the header zone entry.
      # It can then be accessed using `Timezone::Parser::Zone.last`.
      class << self ; attr_accessor :last ; end

      def self.parse(line)
        if match = line.match(HEADER)
          self.last = match[1]
        end

        # match = line.match(TIME_ENTRY)
        # match ||= line.match(INT_ENTRY)
        # raise "INVALID" if match.nil?

        parts = line.split(' ')
        parts.delete(/^\s+$/)
        if match
          parts = parts[2..-1]
        end

        @@zones[last] << Entry.new(last, *parts)
      end
    end
  end
end

require 'timezone/parser/zone/entry'
