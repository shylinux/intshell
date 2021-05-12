#!/bin/sh

ish_sys_date_date() { date +"%Y-%m-%d"; }
ish_sys_date() { date +"%Y-%m-%d %H:%M:%S"; }
ish_sys_date_time() { date +"%H:%M:%S"; }

ish_sys_date_year() { date +"%Y"; }
ish_sys_date_month() { date +"%m"; }
ish_sys_date_day() { date +"%d"; }

ish_sys_date_hour() { date +"%H"; }
ish_sys_date_minute() { date +"%M"; }
ish_sys_date_second() { date +"%S"; }

ish_sys_date_weekday() { date +"%w"; }
ish_sys_date_timezone() { date +"%z"; }

ish_sys_date_filename() { date +"%Y%m%d_%H%M%S"; }

