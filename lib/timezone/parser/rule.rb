require 'time'

module Timezone
  module Parser
    # All the rules that are parsed are stored in the `@@rules` hash by name.
    @@rules = {}
    def self.rules ; @@rules ; end

    RULE = /Rule\s+([\w-]+?)\s+(\d+?)\s+([^\s]+?)\s+([^\s]+?)\s+(\s*\w+?)\s+([\d\w\=\>\<]+?)\s+([\d:us]+?)\s+([\d:]+?)\s+([\w-]+)/

    # Given a line from the TZDATA file, generate a Rule object.
    def self.rule(line)
      RuleGenerator.generate(line)
    end

    module RuleGenerator
      class << self
        def generate(line)
          name, from, to, type, month, day, time, save, letter = \
            *line.match(RULE)[1..-1]

          years(from, to).each do |year|
            Rule.new(name, year, type, month, day, time, save, letter)
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
          when 'max' then 2050
          else to.to_i
          end
        end
      end
    end

    class Rule
      attr_accessor :offset, :name

      def initialize(name, year, type, month, day, time, save, letter)
        @name, @year, @type, @month, @day, @time, @save, @letter = \
          name, year, type, month, day, time, save, letter

        @month, @day = month_day(year)

        @time = "0#{@time}" if @time.match(/^\d:\d\d/)
        @day = "0#{@day}" if @day.match(/^\d$/)

        if @time.match(/^.*u$/)
          @utime = true
          @time = @time.gsub(/u/, '')
        elsif @time.match(/^.*s$/) # TODO What is s time?
          @stime = true
          @time = @time.gsub(/s/, '')
        end

        @offset = parse_offset

        Timezone::Parser.rules[name] ||= []
        Timezone::Parser.rules[name] << self
      end

      # The day the rule starts (in UTC) on the given year.
      def start_date
        parsed = Time.strptime(
          "#{@year} #{@month} #{@day} #{@time} UTC",
          '%Y %b %d %H:%M %Z')

        (parsed + (@utime ? offset : 0)).to_i * 1_000
      end

      # Does this rule have daylight savings time?
      def dst?
        @save != '0'
      end

      # Create a new rule with an offset based on the given entry.
      def apply(entry)
        dup.tap do |rule|
          rule.offset = entry.offset + offset
        end
      end

      private

      def month_day(year)
        if match = @day.match(/^last(\w+)$/)
          31.downto(1).each do |day|
            begin
              date = Time.strptime("#{year} #{@month} #{day}", '%Y %b %d')
              if date.strftime('%a') == match[1]
                return [@month, date.strftime('%d')]
              end
            rescue
              next
            end
          end
        elsif match = @day.match(/^(\w+)>=(\d+)$/)
          day = match[2]
          day = '0'+day if match[2].match(/^\d$/)
          start = Time.strptime("#{year} #{@month} #{match[2]}", '%Y %b %d')

          (1..8).to_a.each do |plus|
            date = start + (plus * 24 * 60 * 60)
            if date.strftime('%a') == match[1]
              return [date.strftime('%b'), date.strftime('%d')]
            end
          end
        else
          [@month, @day]
        end
      end


      def parse_offset
        offset = Time.parse(@save == '0' ? '0:00' : @save)
        offset.hour*60*60 + offset.min*60 + offset.sec
      end
    end
  end
end
