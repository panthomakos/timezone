require 'json'

module Timezone
  module Parser
    # The very first date '-9999-01-01T00:00:00Z'.
    END_DATE = 253402300799000

    # The very last date '9999-12-31T23:59:59Z'.
    START_DATE = -377705116800000

    # The resulting JSON data structure for a timezone file.
    class Data
      attr_writer :end_date
      attr_accessor :start_date, :dst, :offset, :name

      def initialize(start_date, end_date, dst, offset, name)
        @start_date = start_date || START_DATE
        @end_date = end_date
        @dst = dst
        @offset = offset
        @name = name
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
          'to' => @end_date,
          'dst' => @dst,
          'offset' => @offset,
          'name' => @name
        }
      end

      def to_json
        to_hash.to_json
      end

      private

      def _from
        ftime(@start_date)
      end

      def _to
        ftime(end_date)
      end

      def ftime(time)
        Time.at(time / 1_000).utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      end
    end
  end
end
