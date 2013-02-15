require 'json'

module Timezone
  module Parser
    def self.data(*args) ; Data.new(*args) ; end

    def self.from_zone(previous, zone)
      data(previous && previous.end_date, zone.end_date, zone)
    end

    def self.extension(previous, zone)
      data(previous.end_date, nil, zone)
    end

    def self.from_rule(zone, rule)
      data(rule.start_date, nil, zone, rule)
    end

    START_DATE = -377705116800000 # The very last date '9999-12-31T23:59:59Z'.
    END_DATE = 253402300799000 # The very first date '-9999-01-01T00:00:00Z'.

    class NilRule
      def letter ; '-' ; end
      def offset ; 0 ; end
      def utime? ; false ; end
      def dst? ; false ; end
    end

    # The resulting JSON data structure for a timezone file.
    class Data
      attr_accessor :start_date, :dst, :offset, :name

      def initialize(start_date, end_date, zone, rule = NilRule.new)
        @dst = rule.dst?
        @offset = parse_offset(zone, rule)
        @name = parse_name(zone.format, rule.letter)
        @utime = rule.utime?
        @start_date = parse_start_date(start_date)
        self.end_date = end_date
      end

      def end_date=(date)
        if date.nil? || @utime
          @end_date = date
        else
          @end_date = date - (@offset * 1_000)
        end
      end

      def end_date
        @end_date || END_DATE
      end

      def has_end_date?
        !!@end_date
      end

      def to_hash
        {
          '_from' => _from,
          'from' => @start_date,
          '_to' => _to,
          'to' => end_date,
          'dst' => @dst,
          'offset' => @offset,
          'name' => @name
        }
      end

      def to_json
        to_hash.to_json
      end

      private

      def parse_offset(zone, rule)
        zone.offset + rule.offset
      end

      def parse_start_date(date)
        date || START_DATE
      end

      # Fills in a zone entry format with a rule entry letter.
      #
      # Examples:
      #
      #     format "EE%sT" w/ letter "S" results in EEST
      #     format "EE%sT" w/ letter "-" results in EET
      def parse_name(format, letter)
        format.sub(/%s/, letter == '-' ? '' : letter)
      end

      def _from ; ftime(@start_date) ; end
      def _to ; ftime(end_date) ; end

      # Converts a millisecond time into the proper JSON output string.
      def ftime(time)
        Time.at(time / 1_000).utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      end
    end
  end
end
