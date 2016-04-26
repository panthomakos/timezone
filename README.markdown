# Timezone

Accurate current and history timezones for Ruby.

* Uses [tz-database][tz-database] for up-to-date historical timezone calculations.
* Uses the [geonames API][geonames-api] or the [Google Timezone API][google-api] for timezone latitude and longitude lookup.

[tz-database]: http://www.twinsun.com/tz/tz-link.htm
[geonames-api]: http://www.geonames.org/export/web-services.html
[google-api]: https://developers.google.com/maps/documentation/timezone/

## Installation

Use the [`timezone`](https://rubygems.org/gems/timezone) gem - available on RubyGems. Semantic versioning is used, so if you would like to remain up-to-date and avoid any backwards-incompatible changes, use the following in your `Gemfile`:

    gem 'timezone', '~> 0.99'

## NOTE: v1.0.0 Release and Upgrade

Version `1.0.0` of `timezone` will be released in the coming months. The `0.99.*` releases are backwards-forwards-compatible preparatory releases for `1.0.0`. Once `1.0.0` has been released, previous major versions will no longer be updated to include new timezone data. Any method that will be removed in `1.0.0` has been deprecated and warnings are included when deprecated methods are used. There have been some configuration changes - deprecation warnings and upgrade instructions are provided for those as well.

NOTE: once you have upgraded your configuration, deprecated methods will not longer work. For this reason it is recommended that you upgrade your method calls first or that you upgrade everything at once.

Additionally, if you would like to provide your own deprecation logging, you can use `Timezone::Deprecate.callback`. For instance, to log to an external logger, you might use:

    Timezone::Deprecate.callback = lambda do |klass, method, message|
      MyLogger.log("[#{klass} : #{method}] #{message}")
    end

## RubyDocs

Complete documentation for this gem can be found on [RubyDoc](http://www.rubydoc.info/gems/timezone).

## Simple Timezone Queries

Simple querying of time, in any timezone, is accomplished by first retrieving a `Timezone::Zone` object and then calling methods on that object.

    timezone = Timezone['America/Los_Angeles']
    => #<Timezone::Zone name: "America/Los_Angeles">

    timezone.valid?
    => true

    timezone.utc_to_local(Time.now)
    => 2011-02-11 17:29:05 UTC

    timezone.utc_to_local(Time.utc(2010, 1, 1, 0, 0, 0))
    => 2009-12-31 16:00:00 UTC

    timezone.time_with_offset(Time.utc(2010, 1, 1, 0, 0, 0))
    => 2009-12-31 16:00:00 -0800

NOTE: time is always returned in the UTC timezone when using the `utc_to_local` function, but it accurately reflects the actual time in the specified timezone. The reason for this is that this function also takes into account daylight savings time and historical changes in timezone, which can alter the offset. If you want a time with the appropriate offset at the given time, then use the `time_with_offset` function as shown above.

You can use the timezone object to convert local times into the best UTC
estimate. The reason this is an estimate is that some local times do not
actually map to UTC times (for example when time jumps forward) and some
local times map to multiple UTC times (for example when time falls back).

    timezone = Timezone.fetch('America/Los_Angeles')
    => #<Timezone::Zone name: "America/Los_Angeles">

    timezone.local_to_utc(Time.utc(2015,11,1,1,50,0))
    => 2015-11-01 08:50:00 UTC

You can also query a `Timezone::Zone` object to determine if it was in Daylight
Savings Time.

    timezone = Timezone['America/Los_Angeles']
    => #<Timezone::Zone name: "America/Los_Angeles">

    timezone.dst?(Time.now)
    => true

    timezone.dst?(Time.utc(2010, 1, 1, 0, 0, 0))
    => false

For more information on the `::Timezone::Zone` object, see the [RubyDocs](http://www.rubydoc.info/gems/timezone/Timezone/Zone).

## Finding Timezones Based on Latitude and Longitude

`timezone` has the capacity to query Geonames and Google for timezones based on latitude and longitude. Before querying a timezone API you'll need to configure the API you want to use.

### Lookup Configuration with Geonames

1. Ensure you have a Geonames username. It's free and easy to setup, you can do so [here](http://www.geonames.org/login).
1. Ensure you have enabled web services [here](http://www.geonames.org/enablefreewebservice).
1. Configure your lookup. NOTE: in Rails it is recommended that you add this code to an initializer.

        Timezone::Lookup.config(:geonames) do |c|
          c.username = 'your_geonames_username_goes_here'

          # Optional - sets a radius in km to find the timezone
          #            for the closest point of land in the circle
          c.radius = 10
        end

### Lookup Configuration with Google

1. Ensure you have a Google API Key, which you can get [here](https://code.google.com/apis/console/).
1. Enable the Google Maps Time Zone API.
1. Configure your lookup. NOTE: in Rails it is recommended that you add this code to an initializer.

        Timezone::Lookup.config(:google) do |c|
          c.api_key = 'your_google_api_key_goes_here'
          c.client_id = 'your_google_client_id' # if using 'Google for Work'
        end

### Performing Latitude - Longitude Lookups

After configuring the API of your choice, pass the lookup coordinates to `Timezone::lookup`.

    timezone = Timezone.lookup(-34.92771808058, 138.477041423321)
    => #<Timezone::Zone name: "Australia/Adelaide">

    timezone.name
    => "Australia/Adelaide"

    timezone.utc_to_local(Time.now)
    => 2011-02-12 12:02:13 UTC

## Error States and Nil Objects

All exceptions raised by the `timezone` gem are subclasses of `::Timezone::Error::Base`. `timezone` also provides a default `nil` timezone object that behaves like a `Timezone::Zone` except that it is invalid.

    Timezone.fetch('foobar')
    => Timezone::Error::InvalidZone

    Timezone::Error::InvalidZone < Timezone::Error::Base
    => true

    Timezone.fetch('foobar', Timezone['America/Los_Angeles'])
    => #<Timezone::Zone name: "America/Los_Angeles">

    Timezone.fetch('foobar'){ |name| "#{name} is invalid" }
    => "foobar is invalid"

    zone = Timezone['foo/bar']
    => #<Timezone::NilZone>

    zone.valid?
    => false

For more information on errors, check [`::Timezone::Error`](http://www.rubydoc.info/gems/timezone/Timezone/Error).

For more information on the `nil` object, check [`::Timezone::NilZone`](http://www.rubydoc.info/gems/timezone/Timezone/NilZone).

Latitude - longitude lookups can raise `::Timezone::Error::Lookup` exceptions when issues occur with the remote API request. For example, if an API limit is reached. If the request is valid but the result does not return a valid timezone, then an `::Timezone::Error::InvalidZone` exception will be raised, or a default value will be returned if you have provided one.

    Timezone.lookup(10, 10)
    => Timezone::Error::Geonames: api limit reached

    Timezone.lookup(10, 100000)
    => Timezone::Error::InvalidZone

    Timezone.lookup(10, 100000, Timezone::NilZone.new)
    => #<Timezone::NilZone>

    Timezone.lookup(10, 100000){ |name| "#{name} is invalid" }
    => " is invalid"

## Listing Timezones

Retrieving the complete list of timezones can be accomplished using the `::Timezone::names` function. NOTE: the list is not ordered.

    Timezone.names
    => ["EST", "Indian/Comoro", "Indian/Christmas", "Indian/Cocos", ...]


## Using Your Own HTTP Request Handler

If you have non-standard http request needs or want to have more control over API calls to Geonames and Google, you can write your own http request handler instead of using the built-in client.

Here is a sample request handler that uses `open-uri` to perform requests.

    require 'open-uri'

    class MyRequestHandler
      def initialize(config)
        @protocol = config.protocol
        @url = config.url
      end

      Response = Struct.new(:body, :code)

      # Return a response object that responds to #body and #code
      def get(path)
        response = open("#{@protocol}://#{@url}#{path}")

        Response.new(response.read, response.status.first)
      rescue OpenURI::HTTPError
        Response.new(nil, '500')
      end
    end

This custom request handler can be configured for Google or Geonames. For example, to configure with Geonames you would do the following:

    Timezone::Lookup.config(:geonames) do |c|
      c.username = 'foobar'
      c.request_handler = MyRequestHandler
    end

## Testing Timezone Lookups

You can provide your own lookup stubs using the built in `::Timezone::Lookup::Test` class.

    ::Timezone::Lookup.config(:test)
    => #<Timezone::Lookup::Test:... @stubs={}>

    ::Timezone::Lookup.lookup.stub(-10, 10, 'America/Los_Angeles')
    => "America/Los_Angeles"

    ::Timezone.lookup(-10, 10).name
    => 'America/Los_Angeles'

    ::Timezone.lookup(-11, 11)
    => Timezone::Error::Test: missing stub

## Build Status [![Build Status](https://secure.travis-ci.org/panthomakos/timezone.png?branch=master)](http://travis-ci.org/panthomakos/timezone)

## Code Quality [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/panthomakos/timezone)
