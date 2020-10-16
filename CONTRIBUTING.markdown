# How to Contribute

* Bundler is used to manage dependencies.
* Tests can be run with the `rake` command.
* Write tests and create pull requests.

# How to Acquire New TZData Information

* Download and unzip the IANA timezone database (code and data) into the same directory. Use the timezone database README instructions to install. For example:

        make TOPDIR=$HOME/Downloads/tz install

* Provide the root directory (TOPDIR) as the TZPATH environment variable. For example:

        TZPATH=$HOME/Downloads/tz bundle exec rake parse

* Commit changes. For an example, see [this commit](https://github.com/panthomakos/timezone/commit/5815112d7a6c8740844189db0f05281e9c98f58f).

# Notes

* How to read TZData IANA source files: http://www.cstdbill.com/tzdb/tz-how-to.html
