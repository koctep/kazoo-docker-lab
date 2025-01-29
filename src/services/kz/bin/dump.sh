#!/bin/sh

data_dir=/usr/local/kazoo/docs

(
CURL0="curl http://localhost:8000/v2"
CREDS=$(echo -n kazoo:kazoo | md5sum | awk '{print $1}')
AUTH_TOKEN=$($CURL0/user_auth \
  -X PUT \
  -d"{\"data\":{\"account_name\":\"kazoo\",\"credentials\":\"$CREDS\"}}" \
  | jq -r '.auth_token')
ROOT_ACCOUNT_ID=$(jq -Rr 'split(".") | .[1] | @base64d | fromjson | .account_id' <<< $AUTH_TOKEN)

mkdir -p $data_dir
$CURL0/resources/pstn -H "X-Auth-Token: $AUTH_TOKEN" | jq '{data: .data}' \
  > $data_dir/pstn.json

for acc in $($CURL0/accounts/${ROOT_ACCOUNT_ID}/descendants -H "X-Auth-Token: $AUTH_TOKEN" | jq -r '.data[].id'); do
  CURL=$CURL0/accounts/$acc
  mkdir -p $data_dir/$acc
  curl localhost:8000/v2/accounts/$acc -H "X-Auth-Token: $AUTH_TOKEN" | jq '{data: .data}' > $data_dir/$acc/account.json

  TYPES='devices callflows users'
  for TYPE in $TYPES; do
    dir=$data_dir/$acc/$TYPE
    mkdir -p $dir
    for id in $($CURL/$TYPE?paginate=false -H "X-Auth-Token: $AUTH_TOKEN" | jq -r '.data[].id'); do
      doc=$($CURL/$TYPE/$id -H "X-Auth-Token: $AUTH_TOKEN" | jq '{data: .data}')
      [ $TYPE = "users" ] \
        && [ $(echo $doc | jq -r '.data.username') = 'kazoo' ] \
        && echo "skip kazoo user $id" \
        && continue
      echo "$doc" > $dir/$id.json
    done
  done
done
)

