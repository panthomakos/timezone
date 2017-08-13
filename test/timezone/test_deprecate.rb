# frozen_string_literal: true

require 'timezone/deprecate'
require 'minitest/autorun'

class TestDeprecate < ::Minitest::Test
  # This test should not be parallelized because it tests the result
  # of a single class-level attribute.
  def test_callback
    values = []

    Timezone::Deprecate.callback = lambda do |klass, method, message|
      values = [klass, method, message]
    end

    Timezone::Deprecate.call(self, :test_message, 'foo')

    assert_equal [self, :test_message, 'foo'], values
  ensure
    Timezone::Deprecate.callback = nil
  end
end
