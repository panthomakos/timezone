require 'timezone/parser/rule'
require 'timezone/parser/rule/on_rules'
require 'timezone/parser/offset'

module Timezone::Parser::Rule
  class Entry
    attr_accessor :name, :offset
    attr_reader :letter, :start_date

    UTIME = /^.*u$/
    STIME = /^.*s$/
    START_DATE_FORMATS = [
      '%Y %b %d %H:%M %Z',
      '%Y %b %d %H %Z',
    ]

    def initialize(name, year, type, month, day, time, save, letter)
      @name, @offset, @letter = name, offset, letter

      @month, @day = parse_month_day(day, month, year)
      @utime       = parse_utime(time)
      @stime       = parse_stime(time)
      @time        = parse_time(time)
      @day         = parse_day(@day)
      @offset      = parse_offset(save)
      @start_date  = parse_start_date(year, @month, @day, @time)
      @dst         = parse_dst(save)
    end

    def utime? ; @utime ; end
    def stime? ; @stime ; end
    def dst?   ; @dst   ; end

    private

    # Day should be zero padded.
    def parse_day(day)
      '%.2d' % day.to_i
    end

    # Time should be zero padded and not include 'u' or 's'.
    def parse_time(time)
      time = "0#{time}" if time.match(/^\d:\d\d/)
      time = time.gsub(/u/, '') if utime?
      time = time.gsub(/s/, '') if stime?

      time
    end

    def parse_utime(time)
      time =~ UTIME
    end

    def parse_stime(time)
      time =~ STIME
    end

    # The offset is calculated in seconds.
    def parse_offset(offset)
      ::Timezone::Parser::Offset.parse(offset)
    end

    # Check special rules that modify the month and day depending on the year.
    def parse_month_day(day, month, year)
      On.parse(day, month, year)
    end

    # The UTC time on which the rule beings to apply in milliseconds.
    def parse_start_date(y, m, d, t)
      time = [y, m, d, t, 'UTC'].join(' ')

      START_DATE_FORMATS.each do |format|
        begin
          return Time.strptime(time, format).to_i * 1_000
        rescue ArgumentError
          next
        end
      end

      raise "Invalid start date format: '#{time}'."
    end

    def parse_dst(save)
      save != '0'
    end
  end
end
