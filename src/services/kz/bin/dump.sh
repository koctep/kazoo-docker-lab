#!/bin/bash

data_dir=${data_dir:-/usr/local/kazoo/docs}
URL=${URL:-http://localhost:8000}
CREDS=${CREDS:-$(echo -n kazoo:kazoo | md5sum | awk '{print $1}')}
ACCOUNT_NAME=${ACCOUNT_NAME:-kazoo}

(
CURL0="curl $URL/v2"
AUTH_TOKEN=$($CURL0/user_auth \
  -X PUT \
  -d"{\"data\":{\"account_name\":\"${ACCOUNT_NAME}\",\"credentials\":\"$CREDS\"}}" \
  | jq -r '.auth_token')
ROOT_ACCOUNT_ID=$(jq -Rr 'split(".") | .[1] | @base64d | fromjson | .account_id' <<< $AUTH_TOKEN)

mkdir -p $data_dir/system_configs
for conf in $($CURL0/system_configs?paginate=false -H "X-Auth-Token: $AUTH_TOKEN" | jq -r '.data[]'); do
  echo dumping /system_configs/$conf
  $CURL0/system_configs/$conf -H "X-Auth-Token: $AUTH_TOKEN"  | jq '{data: .data}' > $data_dir/system_configs/$conf.json
done

for acc in $($CURL0/accounts/${ROOT_ACCOUNT_ID}/descendants -H "X-Auth-Token: $AUTH_TOKEN" | jq -r '.data[].id'); do
  CURL=$CURL0/accounts/$acc
  mkdir -p $data_dir/$acc
  curl localhost:8000/v2/accounts/$acc -H "X-Auth-Token: $AUTH_TOKEN" | jq '{data: .data}' > $data_dir/$acc/account.json

  TYPES="devices callflows users resources $ADD_TYPES"
  for TYPE in $TYPES; do
    dir=$data_dir/$acc/$TYPE
    mkdir -p $dir
    for id in $($CURL/$TYPE?paginate=false -H "X-Auth-Token: $AUTH_TOKEN" | jq -r '.data[].id'); do
      doc=$($CURL/$TYPE/$id -H "X-Auth-Token: $AUTH_TOKEN" | jq '{data: .data}')
      [ $TYPE = "users" ] \
        && [ $(echo $doc | jq -r '.data.username') = 'kazoo' ] \
        && echo "skip kazoo user $id" >&2 \
        && continue
      echo "$doc" > $dir/$id.json
    done
  done
  echo "renaming to $(jq -r '.data.name' $data_dir/$acc/account.json)" >&2
  mv $data_dir/$acc $data_dir/$(jq -r '.data.name' $data_dir/$acc/account.json)
done
)
