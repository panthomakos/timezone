require 'timezone/parser/rule'
require 'timezone/parser/data'
require 'timezone/parser/zone'
require 'timezone/parser/zone/data_generator'

module Timezone
  module Parser
    COMMENT_REGEXP = /^\s*#/
    RULE_REGEXP    = /^Rule/
    LINK_REGEXP    = /^Link/
    ZONE_REGEXP    = /^Zone/

    def self.parse(file)
      IO.readlines(file).map(&:strip).each do |line|
        if line =~ COMMENT_REGEXP
          next
        elsif line =~ RULE_REGEXP
          rule(line)
        elsif line =~ LINK_REGEXP
          # TODO [panthomakos] Need to add linking.
        elsif line =~ ZONE_REGEXP || (line != '' && !line.nil?)
          zone(line)
        else
          Timezone::Parser::Zone.generate(Timezone::Parser::Zone.last)
        end
      end
    end
  end
end
