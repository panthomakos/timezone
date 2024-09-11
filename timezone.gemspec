# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
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

  s.metadata =    {
    'changelog_uri' => 'https://github.com/panthomakos/timezone/blob/master/CHANGES.markdown'
  }

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`
    .split("\n").map { |f| File.basename(f) }

  s.extra_rdoc_files = ['README.markdown', 'License.txt']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_paths    = ['lib']

  s.add_runtime_dependency('ostruct', '~> 0.6')

  s.add_development_dependency('minitest', '~> 5.8')
  s.add_development_dependency('rake', '~> 13')
  s.add_development_dependency('rubocop', '= 1.5.1')
  s.add_development_dependency('rubocop-performance', '= 1.5.1')
  s.add_development_dependency('timecop', '~> 0.8')
end
