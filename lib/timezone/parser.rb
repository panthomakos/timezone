require 'timezone/parser/rule'
require 'timezone/parser/data'
require 'timezone/parser/zone'
require 'timezone/parser/zone/data_generator'

module Timezone
  module Parser
    # TODO [panthomakos] This needs refactoring.
    def self.parse(file)
      zone = false
      entries = []

      IO.readlines(file).map(&:strip).each do |line|
        next if line =~ /^\s*#/

        if line =~ /^Rule/
          rule(line)
          next
        elsif line =~ /^Zone/
          entries = []
        elsif line =~ /^Link/
          # TODO [panthomakos] Need to add linking.
          next
        end

        if line != '' && !line.nil?
          entries << zone(line)
        else
          process(entries)
          entries = []
        end
      end

      process(entries)
    end

    def self.process(entries)
      return if entries.empty?
      Timezone::Parser::Zone.generate(entries)
    end
  end
end
