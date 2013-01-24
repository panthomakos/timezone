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
        end
      end

      process(entries)
    end

    def self.process(entries)
      return [] if entries.empty?

      rules = []
      previous = nil
      last_entry = nil

      entries.map{ |entry|
        previous = entry.data(previous ? previous.last.end_date : nil, last_entry && last_entry.end_date)
        last_entry = entry
      }.flatten
    end
  end
end
