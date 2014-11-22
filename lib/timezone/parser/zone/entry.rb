require 'timezone/parser/zone'
require 'timezone/parser/zone/until'
require 'timezone/parser/rule'
require 'timezone/parser/offset'
require 'time'

# The data object that represents a zone entry in the TZData file.
# Tests for this class are contained in the parser/zone_test.rb file.
module Timezone::Parser::Zone
  class Entry
    attr_reader :name, :format, :offset, :end_date, :rules

    # name, offset, rule, format, until...
    def initialize(name, offset, *args)
      params = {}

      [:rule, :format, :until].each do |attr|
        if attr == :until
          params[attr] = args.join(' ')
        else
          params[attr] = args.shift
        end
      end

      @name = name
      @format = params[:format]

      @end_date = parse_end_date(params[:until])
      @offset   = parse_offset(offset)
      @rules    = parse_rules(params[:rule], @end_date)
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

    # The offset is calculated in seconds.
    def parse_offset(offset)
      ::Timezone::Parser::Offset.parse(offset)
    end
  end
end
