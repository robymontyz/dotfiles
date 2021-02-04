#!/bin/bash
## Creatte JWT Token
## Small utility to compute a JWT token given the secret.
## Copyright (C) 2019 robymontyz
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
## Usage: create-jwt-token.sh <secret>

# Variables
secret="victory"

# check number of arguments
if [[ $# -ne 1 ]]; then
  echo "No secret provided. Using default: ${secret}"
else
  secret=$1
fi

# Static header fields.
header='{"alg":"HS256","typ":"JWT"}'

# Use jq to set the dynamic `iat` and `exp`
# fields on the header using the current time.
# `iat` is set to now, and `exp` is now + 1 second.
# header=$(
# 	echo "${header}" | jq --arg time_str "$(date +%s)" \
# 	'
# 	($time_str | tonumber) as $time_num
# 	| .iat=$time_num
# 	| .exp=($time_num + 1)
# 	'
# )
payload='{"iss":"WebGoat Token Builder","iat":1524210904,"exp":1618905304,"aud":"webgoat.org","sub":"tom@webgoat.com","username":"WebGoat","Email":"tom@webgoat.com","Role":["Manager","Project Administrator"]}'

base64_encode()
{
	declare input=${1:-$(</dev/stdin)}
	# Use `tr` to URL encode the output from base64.
	printf '%s' "${input}" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}

hmacsha256_sign()
{
	declare input=${1:-$(</dev/stdin)}
	printf '%s' "${input}" | openssl dgst -binary -sha256 -hmac "${secret}"
}

header_base64=$(echo "${header}" | base64_encode)
payload_base64=$(echo "${payload}" | base64_encode)

header_payload=$(echo "${header_base64}.${payload_base64}")

signature=$(echo "${header_payload}" | hmacsha256_sign | base64_encode)

echo "${header_payload}.${signature}"
