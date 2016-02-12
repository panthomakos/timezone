require 'timezone/zone'
require 'timezone/nil_zone'
require 'timezone/lookup'
require 'timezone/loader'

module Timezone
  def self.names
    Loader.names
  end

  def self.[](name)
    fetch(name) { ::Timezone::NilZone.new }
  end

  def self.fetch(name)
    return ::Timezone::Zone.new(name) if Loader.valid?(name)

    return yield(name) if block_given?

    raise ::Timezone::Error::InvalidZone
  end

  def self.lookup(lat, long, &block)
    fetch(::Timezone::Lookup.lookup.lookup(lat, long), &block)
  end
end
