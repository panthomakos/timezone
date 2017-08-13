# frozen_string_literal: true

require 'timezone'
require 'minitest/autorun'
require 'mathn'

class TestTimezone < ::Minitest::Test
  parallelize_me!

  def test_lookup_mathn_compatibility
    Timezone['America/Regina'].utc_offset
  end
end
