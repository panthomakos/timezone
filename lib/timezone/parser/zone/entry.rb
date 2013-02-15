require 'timezone/parser/zone'
require 'timezone/parser/zone/until'
require 'timezone/parser/rule'
require 'time'

module Timezone::Parser::Zone
  class Entry
    attr_reader :name, :format, :offset, :end_date, :rules

    def initialize(name, offset, rule, format, end_date)
      @name, @format = name, format

      @end_date = parse_end_date(end_date)
      @offset   = parse_offset(offset)
      @rules    = parse_rules(rule, @end_date)
    end

    private

    def parse_rules(name, end_date)
      Timezone::Parser.select_rules(name, end_date)
    end

    def parse_end_date(end_date)
      Until.parse(end_date)
    end

    def parse_offset(offset)
      offset = Time.parse(offset)
      offset.hour*60*60 + offset.min*60 + offset.sec
    end
  end
end
