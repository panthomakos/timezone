require 'timezone/lookup/basic'
require 'minitest/autorun'

class BasicLookupTest < ::Minitest::Test
  parallelize_me!

  def config
    @config ||= Struct.new(:protocol, :url).new('http', 'example.com')
  end

  def lookup
    ::Timezone::Lookup::Basic.new(config)
  end

  def test_missing_protocol
    config.protocol = nil
    assert_raises(::Timezone::Error::InvalidConfig) { lookup }
  end

  def test_missing_url
    config.url = nil
    assert_raises(::Timezone::Error::InvalidConfig) { lookup }
  end

  def test_initialization
    assert_equal lookup.config, config
  end
end
