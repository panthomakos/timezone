require 'timezone/parser/rule/on'

module Timezone::Parser::Rule
  On.new 'lastDAY', /^last(\w+)$/, lambda{ |match, _, month, year|
    31.downto(1).each do |day|
      begin
        date = Time.strptime("#{year} #{month} #{day}", '%Y %b %d')
        # If the test day matches the expected day.
        if date.strftime('%a') == match[1]
          return [month, date.strftime('%d')]
        end
      rescue
        next
      end
    end
  }

  On.new 'DAY>=NUM', /^(\w+)>=(\d+)$/, lambda{ |match, _, month, year|
    start = Time.strptime("#{year} #{month} #{match[2]}", '%Y %b %d')

    (1..8).to_a.each do |plus|
      date = start + (plus * 24 * 60 * 60)
      if date.strftime('%a') == match[1]
        return [date.strftime('%b'), date.strftime('%d')]
      end
    end
  }
end
