require 'timezone/parser/zone'
require 'timezone/parser/zone/until'
require 'timezone/parser/rule'
require 'time'

# The data object that represents a zone entry in the TZData file.
# Tests for this class are contained in the parser/zone_test.rb file.
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

    # Only select rules that fall within the timeline of this entry.
    # Then apply the rule to this entry so that the offset is accurate.
    def parse_rules(name, end_date)
      Timezone::Parser.select_rules(name, end_date).sort_by(&:start_date)
    end

    # Use the UNTIL parser to decode the end date.
    def parse_end_date(end_date)
      Until.parse(end_date)
    end

    # The offset is calculated in minutes.
    def parse_offset(offset)
      offset = Time.parse(offset)
      offset.hour*60*60 + offset.min*60 + offset.sec
    end
  end
end
