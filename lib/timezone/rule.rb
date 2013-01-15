module Timezone
  # All the rules that are parsed are stored in the `@@rules` hash by name.
  @@rules = {}
  def self.rules ; @@rules ; end

  # Given a line from the TZDATA file, generate a Rule object.
  def self.rule(line)
    Rule.new(*line.split("\t")[1..9].map(&:strip))
  end

  Rule = Struct.new(:name, :from, :to, :type, :month, :day, :time, :save, :letter) do
    def initialize(name, *args)
      super.tap do |rule|
        Timezone.rules[name] ||= []
        Timezone.rules[name] << self
      end
    end

    # Converts hours and minutes to seconds.
    #
    # Example: 1:00 # => 3600
    def offset
      @offset ||= save
        .split(':')
        .reverse
        .each_with_index
        .map{ |number,index| number.to_i*(60**(index+1)) }
        .reduce(&:+)
    end

    # Does this rule have daylight savings time?
    def dst?
      letter == 'D'
    end
  end
end
