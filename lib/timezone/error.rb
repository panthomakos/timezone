module Timezone
  # Error messages that can be raised by this gem. To catch any
  # related error message, use Error::Base.
  #
  #   begin
  #     ...
  #   rescue Timezone::Error::Base => e
  #     puts "Timezone Error: #{e.message}"
  #   end
  module Error
    # Top-level error. All other timezone errors subclass this one.
    class Base < StandardError; end
    # Indicates an invalid timezone name.
    class InvalidZone < Base; end
    # @deprecated this class will be removed in the next release of the gem.
    class NilZone < Base; end
    # Indicates a lookup failure.
    class Lookup < Base; end
    # Indicates an error during lookup using the geonames API.
    class GeoNames < Lookup; end
    # Indicates an error during lookup using the google API.
    class Google < Lookup; end
    # @deprecated this class will be removed in the next release of the gem.
    class ParseTime < Base; end
    # Indicates a missing stub during a test lookup.
    class Test < Lookup; end
    # Indicates an invalid configuration.
    class InvalidConfig < Base; end
  end
end
