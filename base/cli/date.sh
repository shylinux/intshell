#!/bin/sh

ish_ctx_date_date() { date +"%Y-%m-%d"; }
ish_ctx_date() { date +"%Y-%m-%d %H:%M:%S"; }
ish_ctx_date_time() { date +"%H:%M:%S"; }

ish_ctx_date_year() { date +"%Y"; }
ish_ctx_date_month() { date +"%m"; }
ish_ctx_date_day() { date +"%d"; }

ish_ctx_date_hour() { date +"%H"; }
ish_ctx_date_minute() { date +"%M"; }
ish_ctx_date_second() { date +"%S"; }

ish_ctx_date_weekday() { date +"%w"; }
ish_ctx_date_timezone() { date +"%z"; }

