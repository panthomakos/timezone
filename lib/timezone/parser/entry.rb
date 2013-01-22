require 'timezone/parser/rule'
require 'timezone/parser/data'
require 'time'

module Timezone
  module Parser
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

    # An entry from the TZData file.
    class Entry
      attr_reader :name, :format

      def initialize(name, offset, rule, format, end_date)
        @name = name
        @offset = offset
        @rule = rule
        @format = format
        @end_date = end_date
      end

      # Rules that this TZData entry references.
      def rules
        Timezone::Parser.rules[@rule]
      end

      # The integer offset of this entry.
      def offset
        @time ||= Time.parse(@offset)
        @time.hour*60*60 + @time.min*60 + @time.sec
      end

      # Formats for the UNTIL value in the TZData entry.
      UNTIL_FORMATS = [
        '%Y %b', # 1900 Oct
        '%Y %b %-d', # 1948 May 15
      ]

      # The integer value of UNTIL with offset taken into consideration.
      def end_date
        UNTIL_FORMATS.each do |format|
          begin
            time = Time.strptime(@end_date+' UTC', format+' %Z')
            return (time - offset).to_i * 1_000
          rescue ArgumentError
            next
          end
        end

        nil
      end

      def data # Eventually want to pass the existing entries in here.
        [Data.new(nil, end_date, false, offset, format)]
      end
    end
  end
end
