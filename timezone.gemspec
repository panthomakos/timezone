# frozen_string_literal: true
# -*- encoding: utf-8 -*-

$:.push File.expand_path('../lib', __FILE__)
require 'timezone/version'

Gem::Specification.new do |s|
  s.name        = 'timezone'
  s.version     = Timezone::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pan Thomakos']
  s.email       = ['pan.thomakos@gmail.com']
  s.homepage    = 'https://github.com/panthomakos/timezone'
  s.summary     = "timezone-#{Timezone::VERSION}"
  s.license     = 'MIT'
  s.description = 'Accurate current and historical timezones for Ruby with ' \
    'support for Geonames and Google latitude - longitude lookups.'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`
    .split("\n").map { |f| File.basename(f) }

  s.extra_rdoc_files = ['README.markdown', 'License.txt']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_paths    = ['lib']

  s.add_development_dependency('minitest', '~> 5.8')
  s.add_development_dependency('rake', '~> 12')
  s.add_development_dependency('rubocop', '= 0.51')
  s.add_development_dependency('timecop', '~> 0.8')
end
