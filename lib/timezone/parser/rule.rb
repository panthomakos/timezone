require 'time'

module Timezone
  module Parser
    def self.rule(line) ; Rule.generate(line) ; end
    def self.rules ; Rule.rules ; end

    module Rule
      RULE = /Rule\s+([\w-]+?)\s+(\d+?)\s+([^\s]+?)\s+([^\s]+?)\s+(\s*\w+?)\s+([\d\w\=\>\<]+?)\s+([\d:us]+?)\s+([\d:]+?)\s+([\w-]+)/
      END_YEAR = 2050

      @@rules = {}
      def self.rules ; @@rules ; end

      class << self
        def generate(line)
          name, from, to, type, month, day, time, save, letter = \
            *line.match(RULE)[1..-1]

          years(from, to).map do |year|
            @@rules[name] ||= []
            @@rules[name] << Entry.new(name, year, type, month, day, time, save, letter)
          end
        end

        private

        # The years that the rule applies to.
        def years(from, to)
          (from.to_i..end_year(from, to)).to_a
        end

        def end_year(from, to)
          case to
          when 'only' then from.to_i
          when 'max' then END_YEAR
          else to.to_i
          end
        end
      end
    end
  end
end

require 'timezone/parser/rule/entry'
