# frozen_string_literal: true

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
  # @param default an object to return if timezone is
  #   not found
  # @yield the block to run if the timezone is not found
  # @yieldparam name [String] the timezone name if the timezone is not
  #   found
  #
  # @return [Timezone::Zone] if the timezone is found
  # @return [Object] if the timezone is not found and a default
  #   value or block has been provided
  #
  # @raise [Timezone::Error::InvalidZone] if the timezone is not found
  #   and a default value and block have not been provided
  def self.fetch(name, default = :__block, &block)
    return ::Timezone::Zone.new(name) if Loader.valid?(name)

    if block_given? && default != :__block
      warn('warning: block supersedes default value argument')
    end

    return block.call(name) if block_given?
    return default unless default == :__block

    raise ::Timezone::Error::InvalidZone
  end

  # Lookup a timezone name by (lat, long) and then fetch the
  # timezone object.
  #
  # @param lat [Double] the latitude coordinate
  # @param long [Double] the longitude coordinate
  # @param default an optional object to return if the remote lookup
  #   succeeds but the timezone is not found
  # @yield the block to run if the remote lookup succeeds and the
  #   timezone is not found
  # @yieldparam name [String] the timezone name if the remote lookup
  #   succeeds and the timezone is not found
  #
  # @return [Timezone::Zone] if the remote lookup succeeds and the
  #   timezone is found
  # @return [Object] if the remote lookup succeeds, the timezone is
  #   not found, and a default value or block has been provided
  #
  # @raise [Timezone::Error::InvalidZone] if the remote lookup
  #   succeeds but the resulting timezone is not found and a default
  #   value or block has not been provided
  # @raise [Timezone::Error::Lookup] if the remote lookup fails
  def self.lookup(lat, long, default = :__block, &block)
    fetch(::Timezone::Lookup.lookup.lookup(lat, long), default, &block)
  end
end
