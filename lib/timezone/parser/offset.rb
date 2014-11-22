module Timezone
  module Parser
    module Offset
      class << self
        FORMATS = [
          '%H:%M:%S',
          '%H:%M',
          '%H',
        ]

        def parse(offset)
          sign = offset.start_with?('-') ? -1 : 1
          offset = offset.gsub('-','')
          offset = parse_time(offset)
          sign * (offset.hour*60*60 + offset.min*60 + offset.sec)
        rescue
          offset.to_i
        end

        private

        def parse_time(offset)
          FORMATS.each do |format|
            begin
              return Time.strptime(offset, format)
            rescue ArgumentError
              next
            end
          end

          nil
        end
      end
    end
  end
end
