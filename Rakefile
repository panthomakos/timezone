require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :test

task :parse do
  LINE = /\s*(.+)\s*=\s*(.+)\s*isdst=(\d+)\s*gmtoff=([\+\-]*\d+)/
  FORMAT = '%a %b %e %H:%M:%S %Y %Z'

  require 'time'

  Dir['/usr/share/zoneinfo/right/**/*'].each do |file|
    next if File.directory?(file)
    zone = file.gsub('/usr/share/zoneinfo/right/','')
    print "Parsing #{zone}... "
    data = `zdump -v right/#{zone}`
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
    system("mkdir -p data/#{File.dirname(zone)}")
    f = File.open("data/#{zone}", 'w')
    f.write(result.map{ |k| k.join(':') }.join("\n"))
    f.close
    puts 'DONE'
  end
end
