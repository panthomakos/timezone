# Timezone

Accurate current and history timezones for Ruby.

* Uses [tz-database][tz-database] for up-to-date historical timezone calculations.
* Uses the [geonames API][geonames-api] or the [Google Timezone API][google-api] for timezone latitude and longitude lookup.

[tz-database]: http://www.twinsun.com/tz/tz-link.htm
[geonames-api]: http://www.geonames.org/export/web-services.html
[google-api]: https://developers.google.com/maps/documentation/timezone/

## Installation

Use the [`timezone`](https://rubygems.org/gems/timezone) gem - available on RubyGems. Semantic versioning is used, so if you would like to remain up-to-date and avoid any backwards-incompatible changes, use the following in your `Gemfile`:

    gem 'timezone', '~> 1.0'

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

    timezone.abbr(Time.new(2016, 9, 4, 1, 0, 0))
    => "PDT"

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

### Latitude - Longitude Lookups for [Etcetera](https://www.ietf.org/timezones/data/etcetera) areas

By default both Geonames and Google do not provide results for lookups outside of continents and country borders. For example, if you try coordinates `[0, 0]` (somewhere in the Atlantic Ocean), you will get an exception.

But there is a way to get lookups for the whole Earth surface working (with Geonames only). Just add the `offset_etc_areas` option to the lookup configuration:

        Timezone::Lookup.config(:geonames) do |c|
          c.username = 'your_geonames_username_goes_here'
          c.offset_etc_zones = true
        end

Then try to lookup coordinates in Etc area:

    timezone = Timezone.lookup(89, 40)
    => #<Timezone::Zone name: "Etc/GMT-3">

    timezone.name
    => "Etc/GMT-3"

    timezone.utc_offset
    => 10800

NOTE: `Etc/GMT` zones have POSIX-style signs in their names, with positive signs west of Greenwich. For example, "Etc/GMT-3" zone has a negative sign, but a positive UTC offset (10800 seconds or +3 hours) and its time is ahead of UTC (east of Greenwich) by 3 hours.

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

## Using Geonames and Google Lookups

`timezone` can be configured to use both Google and Geonames lookups. For instance, you may choose to fallback to Google if a Geonames lookup fails. The return value from a `::Timezone::Lookup.config` call can be stored and re-used to trigger lookups for the configured service. For instance:

    GEONAMES_LOOKUP = Timezone::Lookup.config(:geonames) { |c| c.username = ... }
    GOOGLE_LOOKUP = Timezone::Lookup.config(:google) { |c| c.api_key = ... }

    lat, lon = 89, 40

    begin
      GEONAMES_LOOKUP.lookup(lat, lon)
    rescue ::Timezone::Error::Lookup
      GOOGLE_LOOKUP.lookup(lat, lon)
    end

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
    
You can also provide a fallback lookup, which will be returned if you query an un-stubbed lookup value.

    ::Timezone::Lookup.lookup.default('America/Los_Angeles')
    => "America/Los_Angeles"

## Build Status [![Build Status](https://app.travis-ci.com/panthomakos/timezone.svg?branch=master)](https://secure.travis-ci.org/panthomakos/timezone.png?branch=master)

## Code Quality [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/panthomakos/timezone)
