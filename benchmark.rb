#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'timezone'

puts 'Loading timezones'

Benchmark.bm do |x|
  x.report('la') { 10_000.times { Timezone.fetch('America/Los_Angeles') } }
  x.report('hk') { 10_000.times { Timezone.fetch('Asia/Hong_Kong') } }
end

def calc(method, timezone, time)
  timezone.public_send(method, time)
end

def bench(iterations, method)
  Benchmark.bm do |x|
    time = Time.utc(3000, 1, 1)
    timezone = Timezone.fetch('America/Los_Angeles')
    x.report('la') { iterations.times { calc(method, timezone, time) } }
    timezone = Timezone.fetch('Asia/Hong_Kong')
    x.report('hk') { iterations.times { calc(method, timezone, time) } }
  end
end

puts 'Calculating LOCAL (#time)'
bench(10_000, :time)

puts 'Calculating UTC (#local_to_utc)'
bench(10_000, :local_to_utc)
