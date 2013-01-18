module Timezone
  # The very first date '-9999-01-01T00:00:00Z'.
  END_DATE = 253402300799000

  # The very last date '9999-12-31T23:59:59Z'.
  START_DATE = -377711769600000

  # The resulting JSON data structure for a timezone file.
  # TODO: Add tests for this class.
  Data = Struct.new(:from, :to, :dst, :offset, :name) do
    def from
      @from || START_DATE
    end

    def to
      @to || END_DATE
    end
  end
end
