require 'time'

module Timezone
  class Parser
    LINE = /\s*(.+)\s*=\s*(.+)\s*isdst=(\d+)\s*gmtoff=([\+\-]*\d+)/
    FORMAT = '%a %b %e %H:%M:%S %Y %Z'

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

    def parse(file)
      zone = file.gsub("#{zoneinfo}/right/",'')
      print "Parsing #{zone}... "
      data = zdump(zone)

      last = 0
      result = []
      data.split("\n").each do |line|
        match = line.gsub('right/'+zone+' ','').match(LINE)
        next if match.nil?

        source = Time.strptime(match[1]+'C', FORMAT).to_i
        name = match[2].split(' ').last
        dst = match[3].to_i
        offset = match[4].to_i

        # If we're just repeating info, pop the last one and
        # add an inclusive rule.
        if result.last &&
          result.last[1] == name &&
          result.last[2] == dst &&
          result.last[3] == offset
            last -= result.last[0]
            result.pop
        end

        temp = source
        source = source - last
        last = temp

        result << [source, name, dst, offset]
      end

      write(zone, result)
      puts 'DONE'
    end

    def zdump(zone)
      return `zdump -v right/#{zone}`
    end

    def write(zone, data)
      system("mkdir -p data/#{File.dirname(zone)}")
      f = File.open("data/#{zone}", 'w')
      f.write(data.map{ |k| k.join(':') }.join("\n"))
      f.close
    end
  end
end
