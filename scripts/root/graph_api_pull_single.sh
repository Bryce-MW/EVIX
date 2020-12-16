#!/bin/bash
# NOTE(bryce): Originally written by another IX and "borrowed" by Bryce Wilson on 2020-09-11. I can't find the original
#  source.
#  * 2020-11-28|>Bryce|>Remove unused code
#  * 2020-12-09|>Bryce|>Fix some issues causing graphs to not be downloaded

export TZ="UTC"
now=$(date +%s)
seconds_in_day=86400
seconds_in_week=604800
day_ago_seconds=$((now - seconds_in_day))
week_ago_seconds=$((now - seconds_in_week))
out_dir='/evix/run/IX-Website/templates/static/graphs'
token='***REMOVED***'

api_device_id="$1"
server_name="$2"
api_url="http://librenms.evix.org/api/v0/devices"
api_image_path="ports/br10/port_bits"

# TODO(bryce): I am not sure if this is true anymore since we removed the title. We also get SVGs so I don't think that
#  the size even matters at all.
# For the website the image should be 853×225 pixels.
# If you ask for 853×225, you will get 934x264 as there is a
# fixed pad for height and width.  You need to ask for 772x186.

width=541
height=186

curl -H "X-Auth-Token: $token" "$api_url/$api_device_id/$api_image_path?from=$day_ago_seconds&to=$now&width=$width&height=$height" >daily_tmp.svg
mv daily_tmp.svg $out_dir/"$server_name"-daily.svg

curl -H "X-Auth-Token: $token" "$api_url/$api_device_id/$api_image_path?from=$week_ago_seconds&to=$now&width=$width&height=$height" >week_tmp.svg
mv week_tmp.svg $out_dir/"$server_name"-weekly.svg
