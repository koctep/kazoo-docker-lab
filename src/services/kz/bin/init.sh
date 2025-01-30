#!/bin/sh

data_dir=${data_dir:-/usr/local/kazoo/docs}
START_ON_HOST=${START_ON_HOST:-kz}

[ $(hostname | cut -f1 -d.) = "${START_ON_HOST}" ] || exit 2

while [ $(sup kapps_controller running_apps | sed 's/,/\n/g' | wc -l) -lt 18 ]; do
  echo "kazoo not started yet"
  sleep 1
done

echo "kazoo started"
sleep 10
echo "starting initialization"

sup crossbar_maintenance create_account kazoo kazoo kazoo kazoo #&& \
(
sup kazoo_apps_maintenance start ecallmgr
sup kazoo_apps_maintenance start konami
sup crossbar_maintenance init_apps /var/www/html/monster-ui/apps
i=1
while : ; do
  echo "trying fs-$i"
  output=$(host fs-$i)
  [ ! $? -eq 0 ] && break
  sup ecallmgr_maintenance add_fs_node freeswitch@$(echo "$output" | awk '{print $4}')
  i=$(($i + 1))
done

CURL="curl http://localhost:8000/v2"
CREDS=$(echo -n kazoo:kazoo | md5sum | awk '{print $1}')
AUTH_TOKEN=$($CURL/user_auth \
  -X PUT \
  -d"{\"data\":{\"account_name\":\"kazoo\",\"credentials\":\"$CREDS\"}}" \
  | jq -r '.auth_token')
ROOT_ACCOUNT_ID=$(jq -Rr 'split(".") | .[1] | @base64d | fromjson | .account_id' <<< $AUTH_TOKEN)
echo "root account id ${ROOT_ACCOUNT_ID}"

for acc in $(ls -1 $data_dir/*/account.json); do
  ACCOUNT_DIR=$(dirname $acc)
  echo "processing $ACCOUNT_DIR"
  ACCOUNT_ID=$(cat ${acc} | jq -r '.data.id')
  echo "creating account $ACCOUNT_ID"
  curl localhost:8000/v2/accounts/${ROOT_ACCOUNT_ID} -X PUT -H "X-Auth-Token: $AUTH_TOKEN" -d@${acc}
  for f in $(ls -1 $ACCOUNT_DIR/*/*.json); do
    TYPE=$(basename $(dirname $f))
    DATA=@$f
    [ $TYPE = "users" ] && DATA=$(echo $(cat $f) "{\"data\":{\"password\":\"$(pwgen)\"}}" | jq -s '.[0] * .[1]')
    curl localhost:8000/v2/accounts/$ACCOUNT_ID/$TYPE \
      -X PUT -H "X-Auth-Token: $AUTH_TOKEN" \
      -d"$DATA" | jq
  done
done

exit 0
)
