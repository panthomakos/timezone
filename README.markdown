# Timezone

A simple way to get accurate current and historical timezone information based on zone or latitude and longitude coordinates. This gem uses the [tz database](http://www.twinsun.com/tz/tz-link.htm) for historical timezone information. It also uses the [geonames API](http://www.geonames.org/export/web-services.html) for timezone latitude and longitude lookup.

## Installation

Add the following to your Gemfile:

    gem 'timezone'

Then install your bundle.

    bundle install

## Getting Started

Getting the current time or any historical time in any timezone, with daylight savings time taken into consideration, is easy:

    timezone = Timezone::Zone.new :zone => 'America/Los_Angeles'
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

    timezone = Timezone::Zone.new :latlon => [-34.92771808058, 138.477041423321]
    timezone.zone
    => "Australia/Adelaide"
    timezone.time Time.now
    => 2011-02-12 12:02:13 UTC

Also, you can display time zone in the Rails way

    timezone = Timezone::Zone.new :latlon => [-34.92771808058, 138.477041423321]
    timezone.active_support_time_zone
    => "Eastern Time (US & Canada)"


## Getting the complete list of timezones.

Retrieving the complete list of timezones is quite simple:

    timezones = Timezone::Zone.names
    => ["Africa/Abidjan", "Africa/Accra", "Africa/Addis_Ababa", "Africa/Algiers", ...]
    
## Listing current information from specific timezones

If you need information from a specific set of timezones rather than a complete list or one at a time, this can be accomplished with the following:

    zone_list = Timezone::Zone.list "America/Chicago", "America/New_York", "America/Boise"
    # This will return an array of information hashes in the following format:
    # { 
    #   :zone => "America/Chicago",
    #   :title => "America/Chicago", # this can be customized to your needs
    #   :offset => -18000, # UTC offset in seconds
    #   :utc_offset => -5, # UTC offset in hours
    #   :dst => false
    # }
    
You can customize what is placed in the `:title` key in the configuration block. This would be useful in the case of an HTML select list that you would like to display different values than the default name.  For example, the following configuration will set the `:title` key in the list hash to "Chicago" rather than "America/Chicago".

    Timezone::Configure.build do |c|
      c.replace "America/Chicago", with: "Chicago"
    end
    
Also, if you make numerous calls to the **Zone#list** method in your software, but you would like to avoid duplicating which timezones to retrieve, you can set a default in the configuration:

    Timezone::Configure.begin do |c|
      c.default_for_list = "America/Chicago", "America/New_York", "Australia/Sydney"
    end
    
Finally, by default the **Zone#list** method will order the results by the timezone's UTC offset. You can customize this behavior this way:

    Timezone::Configure.begin do |c|
      # this can equal any hash key returned by the Zone#list method
      c.order_list_by = :title 
    end

## Build Status [![Build Status](https://secure.travis-ci.org/chebyte/timezone.png?branch=master)](http://travis-ci.org/chebyte/timezone)

## Code Quality [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/chebyte/timezone)
