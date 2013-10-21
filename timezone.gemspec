# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "timezone/version"

Gem::Specification.new do |s|
  s.name        = "timezone"
  s.version     = Timezone::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Pan Thomakos"]
  s.email       = ["pan.thomakos@gmail.com"]
  s.homepage    = "http://github.com/panthomakos/timezone"
  s.summary     = "timezone-#{Timezone::VERSION}"
  s.description = %q{A simple way to get accurate current and historical timezone information based on zone or latitude and longitude coordinates. This gem uses the tz database (http://www.twinsun.com/tz/tz-link.htm) for historical timezone information. It also uses the geonames API for timezone latitude and longitude lookup (http://www.geonames.org/export/web-services.html).}

  s.rubyforge_project = "timezone"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ['README.markdown', 'License.txt']
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ["lib"]

  s.add_development_dependency('rake')
  s.add_development_dependency('minitest', '~> 4.0')
  s.add_development_dependency('timecop')
end
