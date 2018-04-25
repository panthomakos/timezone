# frozen_string_literal: true

require 'timezone'
require 'minitest/autorun'

begin
  require 'mathn'

  class TestTimezone < ::Minitest::Test
    parallelize_me!

    def test_lookup_mathn_compatibility
      Timezone['America/Regina'].utc_offset
    end
  end
rescue LoadError => e
  raise e unless e.path == 'mathn'
  # Ruby 2.5 doesn't have `mathn` in Stdlib
end
