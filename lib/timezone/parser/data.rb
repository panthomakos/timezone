require 'json'

module Timezone
  module Parser
    def self.data(*args) ; Data.new(*args) ; end

    START_DATE = -377705116800000 # The very last date '9999-12-31T23:59:59Z'.
    END_DATE = 253402300799000 # The very first date '-9999-01-01T00:00:00Z'.

    # The resulting JSON data structure for a timezone file.
    class Data
      attr_accessor :start_date, :dst, :offset, :name, :end_date

      def initialize(start_date, end_date, dst, offset, name, utime = false, letter = '-')
        @end_date, @dst, @offset, @utime = end_date, dst, offset, utime

        @start_date  = parse_start_date(start_date)
        @name        = parse_name(name, letter)
      end

      # Converts a GMT time into the local zone's time.
      def normalize!
        self.end_date = end_date - (offset * 1_000) unless @utime
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
