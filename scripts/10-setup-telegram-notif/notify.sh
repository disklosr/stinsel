#!/bin/bash
curl --header "Content-Type: application/json" \
     --request POST \
     --data "{\"chat_id\": \"{{chat_id}}\", \"text\": \"$1\"}" \
     -sS https://api.telegram.org/bot{{bot_token}}/sendMessage > /dev/null