require 'timezone/parser/zone'
require 'time'

module Timezone::Parser::Zone
  module Until
    # Formats for the UNTIL value in the TZData entry.
    FORMATS = [
      '%Y %b', # 1900 Oct
      '%Y %b %e', # 1948 May 15
    ]

    # The integer value of UNTIL with offset taken into consideration.
    def self.parse(end_date)
      FORMATS.each do |format|
        begin
          return Time.strptime(end_date+' UTC', format+' %Z').to_i * 1_000
        rescue ArgumentError
          next
        end
      end

      nil
    end
  end
end
