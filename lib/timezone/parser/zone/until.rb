require 'timezone/parser/zone'
require 'time'

# Responsible for parsing the UNTIL value of a TZData zone entry.
module Timezone::Parser::Zone
  module Until
    FORMATS = [
      '%Y %b', # 1900 Oct
      '%Y %b %e', # 1948 May 15
    ]

    # Tries to parse the date using FORMATS. If parsing of one format fails
    # (raises and ArgumentError) then try the next format.
    #
    # Returns the millisecond value of date.
    def self.parse(date)
      FORMATS.each do |format|
        begin
          return Time.strptime(date+' UTC', format+' %Z').to_i * 1_000
        rescue ArgumentError
          next
        end
      end

      nil
    end
  end
end
