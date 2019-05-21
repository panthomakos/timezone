# frozen_string_literal: true

require 'timezone/error'

module Timezone # rubocop:disable Style/Documentation
  # Responsible for loading and parsing timezone data from files.
  module Loader
    ZONE_FILE_PATH = File.expand_path(File.dirname(__FILE__) + '/../../data')
    SOURCE_BIT = 0

    @rules = {} # cache of loaded rules

    class << self
      def load(name)
        @rules.fetch(name) do
          raise ::Timezone::Error::InvalidZone unless valid?(name)

          @rules[name] = parse_zone_data(get_zone_data(name))
        end
      end

      def names
        @names ||= parse_zone_names
      end

      def valid?(name)
        names.include?(name)
      end

      private

      def parse_zone_names
        files = Dir[File.join(ZONE_FILE_PATH, '**/*')].map do |file|
          next if File.directory?(file)

          file.sub("#{ZONE_FILE_PATH}/", '')
        end

        files.compact
      end

      def parse_zone_data(data)
        rules = []

        data.split("\n").each do |line|
          source, name, dst, offset = line.split(':')
          source = source.to_i
          dst = dst == '1'
          offset = offset.to_i
          source = rules.last[SOURCE_BIT] + source if rules.last
          rules << [source, name, dst, offset]
        end

        rules
      end

      # Retrieve the data from a particular time zone
      def get_zone_data(name)
        File.read(File.join(ZONE_FILE_PATH, name))
      end
    end
  end

  private_constant :Loader
end
