require 'timezone/zone'
require 'timezone/nil_zone'
require 'timezone/lookup'
require 'timezone/loader'

# Main entry point for all timezone related functionality.
module Timezone
  # A list of all timezone names.
  #
  # @return [Array<String>] all the timezone names
  def self.names
    Loader.names
  end

  # Retrieve a timezone by name.
  #
  # @param name [String] the timezone name
  #
  # @return [Timezone::Zone] if the timezone is found
  # @return [Timezone::NilZone] if the timezone is not found
  def self.[](name)
    fetch(name) { ::Timezone::NilZone.new }
  end

  # Fetch a timezone by name.
  #
  # @param name [String] the timezone name
  #
  # @return [Timezone::Zone] if the timezone is found
  # @yield the block to run if the timezone is not found
  # @yieldparam name [String] the timezone name if the timezone is not
  #   found
  # @raise [Timezone::Error::InvalidZone] if the timezone is not found
  #   and a block is not given
  def self.fetch(name)
    return ::Timezone::Zone.new(name) if Loader.valid?(name)

    return yield(name) if block_given?

    raise ::Timezone::Error::InvalidZone
  end

  # Lookup a timezone name by (lat, long) and then fetch the
  # timezone object.
  #
  # @param lat [Double] the latitude coordinate
  # @param long [Double] the longitude coordinate
  # @yield the block to run if the lookup succeeds and the timezone
  #   is not found
  # @yieldparam name [String] the timezone name if the timezone is not
  #   found
  # @raise [Timezone::Error::Lookup] if the lookup fails
  def self.lookup(lat, long, &block)
    fetch(::Timezone::Lookup.lookup.lookup(lat, long), &block)
  end
end
