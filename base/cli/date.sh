#!/bin/sh

${ISH_CTX_SCRIPT}_date() { date +"%Y-%m-%d %H:%M:%S" }
${ISH_CTX_SCRIPT}_date_year() { date +"%Y" }
${ISH_CTX_SCRIPT}_date_month() { date +"%m" }
${ISH_CTX_SCRIPT}_date_day() { date +"%d" }
${ISH_CTX_SCRIPT}_date_hour() { date +"%H" }
${ISH_CTX_SCRIPT}_date_minute() { date +"%M" }
${ISH_CTX_SCRIPT}_date_second() { date +"%S" }
${ISH_CTX_SCRIPT}_date_weekday() { date +"%w" }
${ISH_CTX_SCRIPT}_date_timezone() { date +"%z" }

