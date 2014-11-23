# How to Contribute

* Bundler is used to manage dependencies.
* Tests can be run with the `rake` command.
* Write tests and create pull requests.

# How to Acquire New TZData Information

* Download `tzdataXYZ.tar.gz` from [IANA](http://www.iana.org/time-zones).
* Extract and use `zic` to load data into `/usr/share/zoneinfo`.
* Run `bundle exec rake parse` to parse files in `right/` directory into
  the local `data` directory.

# Notes

* How to read TZData IANA source files:
  http://www.cstdbill.com/tzdb/tz-how-to.html
