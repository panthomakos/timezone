require 'time'

module Timezone
  module Parser
    # Given a rule from a TZDATA file, generate the appropriate rule objects.
    def self.rule(line) ; Rule.generate(line) ; end

    # Get a list of all processed rules.
    def self.rules ; Rule.rules ; end

    # Select rules based on a name and end date.
    def self.select_rules(name, end_date)
      rules.fetch(name){ [] }
        .select{ |rule| end_date.nil? || rule.start_date < end_date }
    end

    module Rule
      # Format:  Rule	NAME	FROM	TO	TYPE	IN	ON	AT	SAVE	LETTER/S
      # Example: Rule	EUAsia	1981	max	-	Mar	lastSun	 1:00u	1:00	S
      RULE = /Rule\s+([\w-]+?)\s+(\d+?)\s+([^\s]+?)\s+([^\s]+?)\s+(\s*\w+?)\s+([\d\w\=\>\<]+?)\s+([\d:us]+?)\s+([\d:]+?)\s+([\w-]+)/

      END_YEAR = 2050 # The actual value for the "to" field when set to "max".

      # Rules are stored in a hash of arrays that are referenced by rule name.
      @@rules = Hash.new{ |h, k| h[k] = [] }
      def self.rules ; @@rules ; end

      class << self
        def generate(line)
          name, from, to, *values = *line.match(RULE)[1..-1]

          years(from, to).each do |year|
            @@rules[name] << Entry.new(name, year, *values)
          end
        end

        private

        def years(from, to)
          (from.to_i..parse_end_year(from, to))
        end

        def parse_end_year(from, to)
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
