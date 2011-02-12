# Timezone

A simple way to get accurate current and historical timezone information based on zone or latitude and longitude coordinates. This gem uses the tz database (http://www.twinsun.com/tz/tz-link.htm) for historical timezone information. It also uses the geonames API for timezone latitude and longitude lookup (http://www.geonames.org/export/web-services.html).

## Installation

Add the following to your Gemfile:

    gem 'timezone'
    
Then install your bundle.

    bundle install

## Getting Started

Getting the current time or any historical time in any timezone, with daylight savings time taken into consideration, is easy:

    timezone = Timezone.new :zone => 'America/Los_Angeles'
    timezone.time Time.now
    => 2011-02-11 17:29:05 UTC
    timezone.time Time.utc(2010, 1, 1, 0, 0, 0)
    => 2009-12-31 16:00:00 UTC
    
Time is always returned in the UTC timezone, but it accurately reflects the actual time in the specified timezone. The reason for this is that this function also takes into account daylight savings time, which can alter the timezone offset and hence put Ruby in the wrong timezone.
    
## Getting the timezone for a specific latitude and longitude

First, make sure you have a geonames username. It's free and easy to setup, you can do so [here](http://www.geonames.org/login).

Second, add the following to your application.rb file, or before you perform a coordinate lookup.

    Timezone::Configure.begin do |c|
      c.username = 'your_geonames_username_goes_here'
    end
    
Finally, pass the coordinates to your timezone initialization function.

    timezone = Timezone.new :latlon => [-34.92771808058, 138.477041423321]
    timezone.zone
    => "Australia/Adelaide"
    timezone.time Time.now
    => 2011-02-12 12:02:13 UTC