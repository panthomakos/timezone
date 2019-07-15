# How to Contribute

* Bundler is used to manage dependencies.
* Tests can be run with the `rake` command.
* Write tests and create pull requests.

# How to Acquire New TZData Information

* Ensure system `tzdata` package is up to date with most recent release from [IANA](http://www.iana.org/time-zones).
* Run `bundle exec rake parse` to parse files in `posix/` directory into the local `data` directory.
* Commit changes. For an example, see [this commit](https://github.com/panthomakos/timezone/commit/5815112d7a6c8740844189db0f05281e9c98f58f).

# Notes

* How to read TZData IANA source files: http://www.cstdbill.com/tzdb/tz-how-to.html
