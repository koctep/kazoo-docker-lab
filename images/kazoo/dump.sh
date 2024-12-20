#!/bin/sh

(
CURL="curl http://localhost:8000/v2"
CREDS=$(echo -n kazoo:kazoo | md5sum | awk '{print $1}')
AUTH_TOKEN=$($CURL/user_auth \
  -X PUT \
  -d"{\"data\":{\"account_name\":\"kazoo\",\"credentials\":\"$CREDS\"}}" \
  | jq -r '.auth_token')
ACCOUNT_ID=$(jq -Rr 'split(".") | .[1] | @base64d | fromjson | .account_id' <<< $AUTH_TOKEN)
CURL=$CURL/accounts/$ACCOUNT_ID

TYPES='devices callflows users'
for TYPE in $TYPES; do
  dir=/usr/local/kazoo/docs/$TYPE
  mkdir -p $dir
  for id in $($CURL/$TYPE -H "X-Auth-Token: $AUTH_TOKEN" | jq -r '.data[].id'); do
    doc=$($CURL/$TYPE/$id -H "X-Auth-Token: $AUTH_TOKEN" | jq '{data: .data}')
    [ $TYPE = "users" ] \
      && [ $(echo $doc | jq -r '.data.username') = 'kazoo' ] \
      && echo "skip kazoo user $id" \
      && continue
    echo "$doc" > $dir/$id.json
  done
done
)

