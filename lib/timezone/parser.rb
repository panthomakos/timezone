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
          puts line
          rule(line)
          next
        elsif line =~ /^Zone/
          entries = []
        end

        if line != '' && !line.nil?
          entries = entry(line)
        else
          process(entries)
        end
      end

      parse(entries)
    end

    def self.process(entries)
      return [] if entries.empty?

      rules = []
      previous = nil

      entries.map{ |entry|
        previous = entry.data(previous ? previous.last.end_date : nil)
      }.flatten
    end
  end
end
