# frozen_string_literal: true

require 'timezone'

# Simple script to validate that lookups are threadsafe.
#
# Usage: bundle exec ruby -Ilib test/threadsafe_lookup.rb USERNAME

raise 'You must specify a geonames username' unless ARGV.first

Timezone::Lookup.config(:geonames) do |c|
  c.username = ARGV.first
end

threads = Array.new(5).map do
  Thread.new { p Timezone.lookup(33.7489954, -84.3879824).name }
end

threads.map(&:join)
