require 'json'

module Timezone
  module Parser
    def self.data(*args) ; Data.new(*args) ; end

    # After all results have been collected, set the adjust dates for each
    # data. A data's end date is based on its own offset. A data's start
    # date is based on the previous data's end date.
    def self.normalize!(set)
      set.each_cons(2) do |first, second|
        first.normalize!
        second.start_date = first.end_date
      end

      set.last.normalize!
    end

    # The very first date '-9999-01-01T00:00:00Z'.
    END_DATE = 253402300799000

    # The very last date '9999-12-31T23:59:59Z'.
    START_DATE = -377705116800000

    # The resulting JSON data structure for a timezone file.
    class Data
      attr_writer :end_date
      attr_accessor :start_date, :dst, :offset, :name

      def initialize(start_date, end_date, dst, offset, name, utime = false, letter = '-')
        @start_date = start_date || START_DATE
        @end_date = end_date
        @dst = dst
        @offset = offset
        @name = parse_name(name, letter)
        @utime = utime
      end

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

      def parse_name(name, letter)
        name.sub(/%s/, letter == '-' ? '' : letter)
      end

      def _from ; ftime(@start_date) ; end
      def _to ; ftime(end_date) ; end

      def ftime(time)
        Time.at(time / 1_000).utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      end
    end
  end
end
