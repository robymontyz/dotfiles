#!/bin/bash
## videos_total_length
## Show total length in hours/minutes for every video in a folder
## Copyright (C) 2018 robymontyz
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
##
## Usage: video_total_length.sh

seconds="$(find . -iname '*.mp4' -exec ffprobe -v quiet -of csv=p=0 -show_entries format=duration {} \; | awk '{ s = s+$1 }; END { print s+0 }')"

# convert to hh:mm
let minutes=$seconds/60%60
let hours=$seconds/60/60
echo "$hours hours and $minutes minutes"

