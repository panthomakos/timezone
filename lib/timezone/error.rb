module Timezone
  # Error messages that can be raised by this gem. To catch any related error message, simply use Error::Base.
  #
  #   begin
  #     ...
  #   rescue Timezone::Error::Base => e
  #     puts "Timezone Error: #{e.message}"
  #   end
  module Error
    class Base < StandardError; end
    class InvalidZone < Base; end
    class NilZone < Base; end
    class GeoNames < Base; end
    class ParseTime < Base; end
  end
end