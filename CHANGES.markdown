# master (unreleased)

# 1.3.15

* Updated with `tzdata-2021e` ([@panthomakos][])

# 1.3.14

* Updated with `tzdata-2021d` ([@panthomakos][])

# 1.3.13

* Updated with `tzdata-2021c` ([@panthomakos][])

# 1.3.12

* Updated with `tzdata-2021a` ([@panthomakos][])

# 1.3.11

* Updated with `tzdata-2020f` ([@panthomakos][])

# 1.3.10

* Updated with `tzdata-2020d` ([@panthomakos][])

# 1.3.9

* Updated with `tzdata-2020c` ([@panthomakos][])

# 1.3.8

* Updated with `tzdata-2020b` ([@panthomakos][])

# 1.3.7

* Updated with `tzdata-2020a` ([@panthomakos][])

# 1.3.6

* Updated with `tzdata-2019c-1` ([@panthomakos][])

# 1.3.5

* Remove `@rules` from `Zone`'s `Marshall::dump`. ([@panthomakos][])
* Updated with `tzdata-2019b-1`. ([@panthomakos][])

# 1.3.4

* Updated with `tzdata-2019a-1`. (panthomakos)

# 1.3.3

* Updated with `tzdata-2018i-1`. (panthomakos)

# 1.3.2

* Updated with `tzdata-2018g-1`. (panthomakos)

# 1.3.1

* Updated with `tzdata-2018f-2`. (panthomakos)

# 1.3.0

* Add `unstub` method for removing test stubs. (arthurnn)
* Fix errors caused by using a frozen time in Ruby 2.4+. (nobu)
* Improve timezone data parsing. (panthomakos)
* Updated with `tzdata-2018e-2`. (panthomakos)

# 1.2.12

* Updated with `tzdata-2018e-1`. (panthomakos)

# 1.2.11

* Updated with `tzdata-2018d-1`. (panthomakos)

# 1.2.10

* Updated with `tzdata-2018c-1`. (panthomakos)

# 1.2.9

* Fix fractional seconds for `time_with_zone` method. (Aupajo)
* Update with `tzdata-2017c-1`. (panthomakos)

# 1.2.8

* Handle `ZERO_RESULTS` response from Google API. (zhublik)

# 1.2.7

* Updated with `tzdata-2017b-1`. (panthomakos)

# 1.2.6

* Updated with `tzdata-2017a-1`. (panthomakos)

# 1.2.5

* Fix [#71](https://github.com/panthomakos/timezone/issues/71): make lookups thread-safe. (panthomakos)

# 1.2.4

* Updated with `tzdata-2016j-1`. (panthomakos)

# 1.2.3

* Updated with `tzdata-2016i-1`. (panthomakos)

# 1.2.2

* Updated with `tzdata-2016h-1`. (panthomakos)

# 1.2.1

* Updated with `tzdata-2016g-1`. (panthomakos)

# 1.2.0

* Added `::Timezone::Zone#abbr` method. (panthomakos)
* Handle GeoNames error code 15 - "no result found". (panthomakos)

# 1.1.1

* Updated with `tzdata-2016f-1`. (panthomakos)

# 1.1.0

* Added support for lookups of `Etc` areas with Geonames (tgrave)
* Changed binary search method of zone for mathn compatibility. (cbillen)
* Allowed a default test stub. (garyharan)
* Updated with `tzdata-2016e-1`. (panthomakos)

# 1.0.0

* Remove deprecated code. (panthomakos)
* Updated with `tzdata-2016d-1`. (panthomakos)
* Improve Geonames exception messaging. (panthomakos)

# 0.99.2

* Updated with `tzdata-2016c-1`. (panthomakos)
* [#51](https://github.com/panthomakos/timezone/issues/51) Fixed syntax for Ruby 1.9.3. (panthomakos)

# 0.99.1

* Updated with `tzdata-2016b-1`. (panthomakos)

# 0.99.0

* Added nice `to_s` and `inspect` methods for `::Timezone::Zone`. (panthomakos)
* Added deprecation warnings for `0.99` and `1.0` release. (panthomakos)
* Upgraded existing objects for `0.99` and `1.0` release. (panthomakos)
* Upgraded configuration for `0.99` and `1.0` release. (panthomakos)
* Added new objects for `0.99` and `1.0` release. (panthomakos)

# 0.6.0

* Added `::Timezone::Lookup::Test`, which provides lookup stubs for testing frameworks. (panthomakos)
* Updated with tzdata-2016a-1. (panthomakos)

# 0.5.0

* Added support for `DateTime` and `Date` objects. (panthomakos)

# 0.4.3

* Updated with tzdata-2015g-1. (panthomakos)

# 0.4.2

* Updated with tzdata-2015f-1. (panthomakos)

# 0.4.1

* Updated with tzdata-2015e-1. (panthomakos)

# 0.4.0

* Added Google Maps for Work signing support. (appfolio)

# 0.3.11

* Fixed `active_support_time_zone` to only include the 149 `ActiveSupport`
  timezones. Eventually this method will be removed entirely. (panthomakos)

# 0.3.10

* Added clearer error messages for invalid configurations. (panthomakos)
* Updated with tzdata-2015d-1. (panthomakos)

# 0.3.9

* Updated with tzdata-2015b-1. (panthomakos)

# 0.3.8

* Updated with tzdata-2015a-1. (panthomakos)

# 0.3.7

* Cache timezone data in memory for performance. (panthomakos)
* Find timezone rule using binary search for performance. (panthomakos)
* Added `Timezone::Zone#local_to_utc` function. (panthomakos)

# 0.3.6

* Added `Timezone::Zone#time_with_offset` functionality. (panthomakos)
* Fixed `Timezone::Zone#names`. (panthomakos)

# 0.3.5

* Updated with tzdata-2014j-1. (panthomakos)

# 0.3.4

* Added support for Google Timezone API. (amnesia7)

# 0.3.3

* Updated parsing code. (panthomakos)
* Updated storage scheme so that it requires less space. (panthomakos)
* Update timezones to tzdata-2014i-1. (panthomakos)

# 0.3.2

* Added `Timezone::Configure::http_client` for configuring alternative http
  clients. (panthomakos)
* Added `Timezone::Configure::protocol` for configuring alternative net
  protocols. (panthomakos)
* Fixed issue w/ code that detects API rate limiting. (panthomakos)

# 0.2.1

* Update JSON data from the tzdata repository. (panthomakos, petergoldstein)

# 0.1.6

* Performance improvement in parsing timezone files. (nessche)

# 0.1.5

* Fixed date parsing around DST. (nessche)
* Upgraded geonames API endpoint. (mattdbridges)

# 0.1.4

* URL for geonames is now configurable. (stravacd)
* `Zone#names` performance improvement. (mattdbridges)
* `Zone#list` now lists timezone information. (mattdbridges)

# 0.1.2

* Fixed `#utc_offset` rule selection. (natemueller)

[@panthomakos]: https://github.com/panthomakos
