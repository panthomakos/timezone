# frozen_string_literal: true

require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb', 'test/**/test_*.rb']
  t.verbose = true
end

RuboCop::RakeTask.new

task(:utc) { ENV['TZ'] = 'UTC' }

task default: %i[utc test rubocop]

task parse: :utc do
  path = ENV['TZPATH'] || File.join(ENV['HOME'], 'Downloads', 'tz')

  require 'timezone/parser'

  Timezone::Parser.new(path).perform
end
