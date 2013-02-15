require 'timezone/parser/zone'
require 'timezone/parser/data'
require 'time'

module Timezone::Parser::Zone
  def self.generate(zones) ; DataGenerator.generate(zones) ; end

  # TODO [panthomakos] This needs refactoring.
  module DataGenerator
    class << self
      def generate(zone)
        zones = Timezone::Parser.zones[zone].to_a

        return if zones.empty?

        set = zones
          .each_cons(2)
          .inject(update(zones.first)) do |set, (previous, zone)|
            update(zone, set, previous && previous.end_date)
        end

        normalize!(set.flatten.compact)
      end

      # After all results have been collected, set the adjust dates for each
      # data. A data's end date is based on its own offset. A data's start
      # date is based on the previous data's end date.
      def normalize!(set)
        set.each_cons(2) do |first, second|
          first.normalize!
          second.start_date = first.end_date
        end

        set.last.normalize!

        set
      end

      private

      def update(zone, set = [], limit = nil)
        additions = [first_addition(zone, set)]

        zone.rules.each do |rule|
          additions.each_with_index do |data, i|
            if rule_applies?(rule, data, limit)
              insert = Timezone::Parser.data(
                rule.start_date,
                data.has_end_date? ? data.end_date : nil,
                rule.dst?,
                rule.offset,
                zone.format,
                rule.utime?,
                rule.letter)

              data.end_date = insert.start_date

              additions.insert(i+1, insert)
            end
          end
        end

        set + additions
      end

      # The rule has to fall within the time range (start_date..end_date)
      # and the rule's start date cannot be over the limit.
      def rule_applies?(rule, data, limit)
        rule.start_date > data.start_date &&
          rule.start_date < data.end_date &&
          (!limit || rule.start_date > limit)
      end

      def first_addition(zone, set)
        previous = set.last

        if zone.rules.empty?
          # If there are no rules, generate a new entry for this time period.
          Timezone::Parser.data(
            previous && previous.end_date,
            zone.end_date,
            false,
            zone.offset,
            zone.format)
        else
          if previous && previous.has_end_date?
            # If the last entry had a hard cutoff end date, create a new
            # addition that picks up from where the last entry left off.
            Timezone::Parser.data(
              previous.end_date,
              nil,
              false,
              zone.offset,
              zone.format)
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
