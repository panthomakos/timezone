# frozen_string_literal: true

require 'timezone/loader'
require 'minitest/autorun'

module Timezone
  class TestLoader < ::Minitest::Test
    parallelize_me!

    def test_load
      assert_equal(
        [[0, 'GMT', false, 0]],
        Loader.load('GMT')
      )

      assert_raises ::Timezone::Error::InvalidZone do
        Loader.load('foo/bar')
      end
    end

    def test_names
      assert Loader.names.include?('GMT')
      assert Loader.names.include?('Europe/Paris')
      refute Loader.names.include?('foo/bar')
    end

    def test_valid?
      assert Loader.valid?('America/Los_Angeles')
      assert Loader.valid?('Europe/Paris')
      refute Loader.valid?('foo/bar')
      refute Loader.valid?(nil)
    end
  end
end
