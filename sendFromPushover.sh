#!/usr/bin/env bash
# Purpose: Send notification to phone - push/send message ios and android using API from my Linux box/vm/server
# Author: Vivek Gite
# Set API stuff 
_token='a7biiubgzgcjjm4pdp8s8wghcxh81k'
_user='udj7y27mkawju5mtmph7r7qxr6ng7b'
 
# Bash function to push notification to my iPhone 
# yes you can push/send message android too using the same function
push_to_mobile(){
	local t="${1:-cli-app}"
	local m="$2"
	[[ "$m" != "" ]] && curl -s \
	  --form-string "token=${_token}" \
	  --form-string "user=${_user}" \
	  --form-string "title=$t" \
	  --form-string "message=$m" \
	  https://api.pushover.net/1/messages.json
}
