require 'timezone/parser/rule'
require 'timezone/parser/rule/on_rules'

module Timezone::Parser::Rule
  class Entry
    attr_accessor :offset, :name, :letter

    def initialize(name, year, type, month, day, time, save, letter)
      @name, @year, @type, @month, @day, @time, @save, @letter = \
        name, year, type, month, day, time, save, letter

      @month, @day = On.parse(day, month, year)

      @time = "0#{@time}" if @time.match(/^\d:\d\d/)
      @day = "0#{@day}" if @day.match(/^\d$/)

      if @time.match(/^.*u$/)
        @utime = true
        @time = @time.gsub(/u/, '')
      elsif @time.match(/^.*s$/) # TODO What is s time?
        @stime = true
        @time = @time.gsub(/s/, '')
      end

      @offset = parse_offset
    end

    def utime?
      @utime
    end

    # The day the rule starts (in UTC) on the given year.
    def start_date
      parsed = Time.strptime(
        "#{@year} #{@month} #{@day} #{@time} UTC",
        '%Y %b %d %H:%M %Z')

      parsed.to_i * 1000
    end

    # Does this rule have daylight savings time?
    def dst?
      @save != '0'
    end

    # Create a new rule with an offset based on the given entry.
    def apply(entry)
      dup.tap do |rule|
        rule.offset = entry.offset + offset
      end
    end

    private

    def parse_offset
      offset = Time.parse(@save == '0' ? '0:00' : @save)
      offset.hour*60*60 + offset.min*60 + offset.sec
    end
  end
end
