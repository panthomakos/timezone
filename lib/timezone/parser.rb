require 'timezone/parser/rule'
require 'timezone/parser/data'
require 'timezone/parser/entry'

module Timezone
  module Parser
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
          # TODO We need to add linking.
          next
        end

        if line != '' && !line.nil?
          entries << entry(line)
        else
          process(entries)
          entries = []
        end
      end

      process(entries)
    end

    def self.process(entries)
      return [] if entries.empty?

      rules = []
      previous = nil

      entries.map{ |entry|
        rules = entry.data(rules, previous && previous.end_date)
        previous = entry
      }.flatten
    end
  end
end
