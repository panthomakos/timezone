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
