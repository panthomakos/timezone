require 'time'

module Timezone
  class Parser
    LINE = /\s*(.+)\s*=\s*(.+)\s*isdst=(\d+)\s*gmtoff=([\+\-]*\d+)/

    ZONEINFO_DIR = '/usr/share/zoneinfo'

    attr_reader :zoneinfo

    def initialize(zoneinfo = ZONEINFO_DIR)
      @zoneinfo = zoneinfo
    end

    def perform
      Dir["#{zoneinfo}/right/**/*"].each do |file|
        next if File.directory?(file)
        parse(file)
      end
    end

    private

    class Line
      attr_accessor :source, :name, :dst, :offset

      SOURCE_FORMAT = '%a %b %e %H:%M:%S %Y %Z'

      def initialize(match)
        self.source = Time.strptime(match[1]+'C', SOURCE_FORMAT).to_i
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

    def parse(file)
      zone = file.gsub("#{zoneinfo}/right/",'')
      print "Parsing #{zone}... "
      data = zdump(zone)

      last = 0
      result = []

      data.split("\n").each do |line|
        match = line.gsub('right/'+zone+' ','').match(LINE)
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

      write(zone, result)
      puts 'DONE'
    end

    def zdump(zone)
      `zdump -v right/#{zone}`
    end

    def write(zone, data)
      system("mkdir -p data/#{File.dirname(zone)}")
      f = File.open("data/#{zone}", 'w')
      f.write(data.map(&:to_s).join("\n"))
      f.close
    end
  end
end
