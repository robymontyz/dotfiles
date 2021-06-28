#!/bin/bash
## Program name
## Description
## Copyright (C) 2021 robymontyz
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
## Usage: name.sh <arg1> <arg2> <arg3>

# Variables
i=0

# check number of arguments
if [[ $# -ne 3 ]]; then
  echo "Error. Insert arguments: "
  read arg
else
  arg=$1
fi

