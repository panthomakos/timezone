require 'time'

module Timezone
  module Parser
    # All the rules that are parsed are stored in the `@@rules` hash by name.
    @@rules = {}
    def self.rules ; @@rules ; end

    RULE = /Rule\s+(\w+?)\s+(\d+?)\s+([^\s]+?)\s+([^\s]+?)\s+(\s*\w+?)\s+(\d+?)\s+([\d:]+?)\s+([\d:]+?)\s+(\w+)/

    # Given a line from the TZDATA file, generate a Rule object.
    def self.rule(line)
      Rule.new(*line.match(RULE)[1..-1])
    end

    class Rule
      attr_accessor :offset

      def initialize(name, from, to, type, month, day, time, save, letter)
        @name, @from, @to, @type, @month, @day, @time, @save, @letter = \
          name, from, to, type, month, day, time, save, letter

        @time = "0#{@time}" if @time.match(/^\d:\d\d/)
        @day = "0#{@day}" if @day.match(/^\d$/)

        @offset = parse_offset

        Timezone::Parser.rules[name] ||= []
        Timezone::Parser.rules[name] << self
      end

      # The day the rule starts (in UTC) on the given year.
      def start_date(year = nil)
        parsed = Time.strptime(
          "#{year || @from} #{@month} #{@day} #{@time} UTC",
          '%Y %b %d %H:%M %Z')

        parsed.to_i * 1_000
      end

      # The years that the rule applies to.
      def years
        @years ||= (@from.to_i..(@to == 'only' ? @from.to_i : @to.to_i)).to_a
      end

      # Does this rule have daylight savings time?
      def dst?
        @letter =~ /^D/
      end

      # Create a new rule with an offset based on the given entry.
      def apply(entry)
        dup.tap do |rule|
          rule.offset = entry.offset + (dst? ? offset : 0)
        end
      end

      private

      def parse_offset
        offset = Time.parse(@save == '0' ? '0:00' : @save)
        offset.hour*60*60 + offset.min*60 + offset.sec
      end
    end
  end
end
