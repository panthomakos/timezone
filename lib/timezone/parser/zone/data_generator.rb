require 'timezone/parser/zone'
require 'timezone/parser/data'
require 'time'

module Timezone::Parser::Zone
  def self.generate(zones) ; DataGenerator.generate(zones) ; end

  def self.data ; DataGenerator.data ; end

  # TODO [panthomakos] This needs refactoring.
  module DataGenerator
    @@data = Hash.new{ |h,k| h[k] = [] }
    def self.data ; @@data ; end

    class << self
      def generate(zone)
        zones = Timezone::Parser.zones[zone].to_a

        return if zones.empty?

        @@data[zone] = zones
          .each_cons(2)
          .inject(update(zones.first)) do |set, (previous, zone)|
            update(zone, set, previous && previous.end_date)
        end
      end

      private

      def update(zone, set = [], limit = nil)
        additions = [first_addition(zone, set)]

        zone.rules.each do |rule|
          data = additions.last

          if rule_applies?(rule, data, limit)
            Timezone::Parser.from_rule(zone, rule).tap do |insert|
              data.end_date = insert.start_date
              # We do this because the start date is always based on the
              # previous entry end date calculation.
              insert.start_date = data.end_date

              additions << insert
            end
          end
        end

        set + additions
      end

      # The rule has to fall within the time range (start_date..limit).
      def rule_applies?(rule, data, limit)
        rule.start_date > data.start_date &&
          (!limit || rule.start_date > limit)
      end

      def first_addition(zone, set)
        previous = set.last

        if zone.rules.empty?
          # If there are no rules, generate a new entry for this time period.
          Timezone::Parser.from_zone(previous, zone)
        else
          if previous && previous.has_end_date?
            # If the last entry had a hard cutoff end date, create a new
            # addition that picks up from where the last entry left off.
            Timezone::Parser.extension(previous, zone)
          else
            # If the last entry did not have a hard cutoff end date, pop it off
            # the stack for use in these calculations.
            set.pop
          end
        end
      end
    end
  end
end
