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

# How to Release

Releases are published by the [Release workflow](.github/workflows/release.yml) using [RubyGems.org Trusted Publishing](https://guides.rubygems.org/trusted-publishing/), so no RubyGems API key is stored anywhere.

* Commit a version bump to `lib/timezone/version.rb` and add a matching `# x.y.z` heading to `CHANGES.markdown`. For an example, see [this commit](https://github.com/panthomakos/timezone/commit/14e6fabcc7792ffd3524344c10f3684f5513cd84).
* Once that commit is on `master`, tag it with the bare version and push the tag:

        git tag 1.3.31
        git push origin 1.3.31

* The workflow checks that the tag matches `Timezone::VERSION` and is on `master`, runs the tests, pushes the gem to RubyGems.org, and creates the GitHub release from the changelog.
* To check the workflow without publishing, run it manually from the Actions tab. A manual run is a dry run: it builds the gem and obtains RubyGems.org credentials, but publishes nothing.

# Notes

* How to read TZData IANA source files: http://www.cstdbill.com/tzdb/tz-how-to.html
