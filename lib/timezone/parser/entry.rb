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

      Entry.new(@@zone_name, *line.match(ENTRY)[1..-1])
    end

    # After all results have been collected, set the adjust dates for each
    # entry. An entry's end date is based on its own offset. An entry's start
    # date is based on the previous entry's end date.
    def self.normalize!(set)
      set.each_cons(2) do |first, second|
        first.end_date = first.end_date - (first.offset * 1_000)
        second.start_date = first.end_date
      end
    end

    # An entry from the TZData file.
    class Entry
      attr_reader :name, :format, :offset

      def initialize(name, offset, rule, format, end_date)
        @name = name
        @offset = parse_offset(offset)
        @rule = rule
        @format = format
        @end_date = end_date
      end

      # Rules that this TZData entry references.
      def rules
        return [] unless Timezone::Parser.rules[@rule]

        @rules ||= Timezone::Parser.rules[@rule].select{ |rule|
          rule.start_date < end_date
        }
      end

      # Formats for the UNTIL value in the TZData entry.
      UNTIL_FORMATS = [
        '%Y %b', # 1900 Oct
        '%Y %b %e', # 1948 May 15
      ]

      # The integer value of UNTIL with offset taken into consideration.
      def end_date
        UNTIL_FORMATS.each do |format|
          begin
            return Time.strptime(@end_date+' UTC', format+' %Z').to_i * 1_000
          rescue ArgumentError
            next
          end
        end

        nil
      end

      def data(start_date = nil)
        set = [Data.new(start_date, end_date, false, offset, format)]

        rules.each do |rule|
          set.each_with_index do |data, i|
            sub = rule.apply(self)

            # If the rule applies.
            if sub.start_date > data.start_date && sub.start_date < data.end_date
              additions = []

              sub.years.each_with_index do |year, i|
                additions << Data.new(
                  sub.start_date(year),
                  sub.start_date(year+1),
                  sub.dst?,
                  sub.offset,
                  format)
              end

              additions.last.end_date = data.end_date
              data.end_date = additions.first.start_date

              set.insert(i+1, *additions)
            end
          end
        end

        set
      end

      private

      def parse_offset(offset)
        offset = Time.parse(offset)
        offset.hour*60*60 + offset.min*60 + offset.sec
      end
    end
  end
end
