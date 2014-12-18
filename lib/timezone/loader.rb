require 'timezone/error'

module Timezone
  module Loader
    ZONE_FILE_PATH = File.expand_path(File.dirname(__FILE__)+'/../../data')
    SOURCE_BIT = 0

    class << self
      def load(zone)
        @rules ||= {}
        @rules[zone] ||= parse_zone_data(get_zone_data(zone))
      end

      def names
        @@names ||= Dir[File.join(ZONE_FILE_PATH, "**/*")].map{ |file|
          next if File.directory?(file)
          file.gsub("#{ZONE_FILE_PATH}/", '')
        }.compact
      end

      private

      def parse_zone_data(data)
        rules = []

        data.split("\n").each do |line|
          source, name, dst, offset = line.split(':')
          source = source.to_i
          dst = dst == '1'
          offset = offset.to_i
          source = rules.last[SOURCE_BIT]+source if rules.last
          rules << [source, name, dst, offset]
        end

        rules
      end

      # Retrieve the data from a particular time zone
      def get_zone_data(zone)
        file = File.join(ZONE_FILE_PATH, zone)

        if !File.exists?(file)
          raise Timezone::Error::InvalidZone, "'#{zone}' is not a valid zone."
        end

        File.read(file)
      end
    end
  end
end
