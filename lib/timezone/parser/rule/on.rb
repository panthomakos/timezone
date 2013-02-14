require 'timezone/parser/rule'
require 'time'

module Timezone::Parser::Rule
  def self.on(*args) ; On.new(*args) ; end

  class On
    @@rules = []

    # Given a Rule `on` field, parse the appropriate day and month.
    def self.parse(day, month, year)
      @@rules.each do |rule|
        if match = day.match(rule.expression)
          return rule.block.call(match, day, month, year)
        end
      end

      [month, day]
    end

    attr_reader :expression, :block

    def initialize(name, expression, block)
      @name = name
      @expression = expression
      @block = block
      @@rules << self
    end
  end
end
