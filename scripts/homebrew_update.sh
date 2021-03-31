#!/bin/bash
## homebrew_update
## Update and clean brew, the packages installer for macOS
## Copyright (C) jb510
## 
## original version:
## https://gist.github.com/jb510/99f12b1ac70f1cf8b780
##
##
## Usage: homebrew_update.sh

# error if not under macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "Homebrew is a package manager for macOS, \
		you are using a different OS." >&2
	exit 1
fi

# check if homebrew is installed
brew help > /dev/null
if [[ $? -ne 0 ]]; then
	echo "Homebrew must be installed." >&2
	exit 1
fi

echo "`date`: RUNNING: brew update"
/usr/local/bin/brew update
echo "`date`: FINISHED: brew update"

echo ""

echo "`date`: RUNNING: brew upgrade"
/usr/local/bin/brew upgrade
echo "`date`: FINISHED: brew upgrade"

echo ""

echo "`date`: RUNNING: brew upgrade --cask"
/usr/local/bin/brew upgrade --cask
echo "`date`: FINISHED:  brew upgrade --cask"

echo ""

echo "`date`: RUNNING: brew cleanup"
/usr/local/bin/brew cleanup
echo "`date`: FINISHED: brew cleanup"

echo ""

echo "`date`: RUNNING: brew cleanup -s"
/usr/local/bin/brew cleanup -s 
echo "`date`: FINISHED: brew cleanup -s"

echo ""

echo "All done! Enjoy a cold one! 🍺 "

echo ""

