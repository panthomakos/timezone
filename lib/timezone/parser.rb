# frozen_string_literal: true

require 'time'

module Timezone
  # @!visibility private
  # Responsible for parsing timezone data into an exportable format.
  class Parser
    MIN_YEAR = -500
    MAX_YEAR = 2039

    LINE = /\s*(.+)\s*=\s*(.+)\s*isdst=(\d+)\s*gmtoff=([\+\-]*\d+)/

    # Bookkeeping files that we do not want to parse.
    IGNORE = ['leapseconds', 'posixrules', 'tzdata.zi'].freeze

    def initialize(root)
      @config = Config.new(root)
    end

    def perform
      FileUtils.rm_rf('data')

      Dir["#{@config.zoneinfo}/**/*"].each do |file|
        next if File.directory?(file)
        next if file.end_with?('.tab')
        next if IGNORE.include?(File.basename(file))
        parse(file)
      end
    end

    # Represents a timezone database config.
    class Config
      def initialize(root)
        @root = root
        @zoneinfo = File.join(@root, 'usr/share/zoneinfo')
        @zdump = File.join(@root, 'usr/bin/zdump')
      end

      attr_reader :root, :zoneinfo, :zdump
    end

    private_constant :Config

    # Represents a single timezone data file line for a reference timezone.
    class RefLine
      def initialize(config, file)
        first =
          `#{config.zdump} -i #{file}`
            .split("\n")
            .reject(&:empty?)
            .reject { |line| line.start_with?('TZ=') }
            .first

        _date, _time, raw_offset, @name = first.split(' ')
        @offset = parse_offset(raw_offset)
      end

      def to_s
        "0:#{@name}:0:#{@offset}"
      end

      private

      def parse_offset(offset)
        arity = offset.start_with?('-') ? -1 : 1

        match = offset.match(/^[\-\+](\d{2})$/)
        arity * match[1].to_i * 60 * 60
      end
    end

    private_constant :RefLine

    # Represents a single timezone data file line.
    class Line
      attr_accessor :source, :name, :dst, :offset

      SOURCE_FORMAT = '%a %b %e %H:%M:%S %Y %Z'.freeze

      def initialize(match)
        self.source = Time.strptime(match[1] + 'C', SOURCE_FORMAT).to_i
        self.name = match[2].split(' ').last
        self.dst = match[3].to_i
        self.offset = match[4].to_i
      end

      def ==(other)
        name == other.name && dst == other.dst && offset == other.offset
      end

      def to_s
        [source, name, dst, offset].join(':')
      end
    end

    private_constant :Line

    private

    def parse(file)
      zone = file.gsub("#{@config.zoneinfo}/", '')
      print "Parsing #{zone}... "
      data = zdump(file)

      last = 0
      result = []

      data.split("\n").each do |line|
        match = line.gsub(/^#{file}\s+/, '').match(LINE)
        next if match.nil?

        line = Line.new(match)

        # If we're just repeating info, pop the last one and
        # add an inclusive rule.
        if result.last && result.last == line
          last -= result.last.source
          result.pop
        end

        temp = line.source
        line.source = line.source - last
        last = temp

        result << line
      end

      result << RefLine.new(@config, file) if result.empty?

      write(zone, result)
      puts 'DONE'
    end

    def zdump(file)
      `#{@config.zdump} -V -c #{MIN_YEAR},#{MAX_YEAR} #{file}`
    end

    def write(zone, data)
      system("mkdir -p data/#{File.dirname(zone)}")
      f = File.open("data/#{zone}", 'w')
      f.write(data.map(&:to_s).join("\n"))
      f.close
    end
  end
end
