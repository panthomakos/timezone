require 'timezone/loader'
require 'minitest/autorun'

module Timezone
  class TestLoader < ::Minitest::Test
    parallelize_me!

    def test_valid?
      assert Loader.valid?('America/Los_Angeles')
      assert Loader.valid?('Europe/Paris')
      refute Loader.valid?('foo/bar')
      refute Loader.valid?(nil)
    end
  end
end
