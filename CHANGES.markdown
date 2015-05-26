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
