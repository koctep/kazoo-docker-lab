#!/bin/sh

[ $(hostname -f) = "kz.kz" ] || exit 2

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
sup ecallmgr_maintenance add_fs_node freeswitch@fs-kz.kz
sup crossbar_maintenance init_apps /var/www/html/monster-ui/apps

CURL="curl http://localhost:8000/v2"
CREDS=$(echo -n kazoo:kazoo | md5sum | awk '{print $1}')
AUTH_TOKEN=$($CURL/user_auth \
  -X PUT \
  -d"{\"data\":{\"account_name\":\"kazoo\",\"credentials\":\"$CREDS\"}}" \
  | jq -r '.auth_token')
ACCOUNT_ID=$(jq -Rr 'split(".") | .[1] | @base64d | fromjson | .account_id' <<< $AUTH_TOKEN)

$CURL/resrouces -X PUT -H "X-Auth-Token: $AUTH_TOKEN" -d@/usr/local/kazoo/docs/psnt.json

CURL=$CURL/accounts/$ACCOUNT_ID
$CURL/phone_numbers/15005005050 -X PUT -H "X-Auth-Token: $AUTH_TOKEN" | jq
$CURL/metaflows -X POST -H "X-Auth-Token: $AUTH_TOKEN" \
  -d'{"data":{"binding_digit":"*", "patterns":{"2(\\d+)":{"module":"transfer", "data":{"takeback_dtmf":"*1"}}}}}' | jq '.'

for f in $(ls -1 /usr/local/kazoo/docs/*/*.json); do
  TYPE=$(basename $(dirname $f))
  DATA=@$f
  [ $TYPE = "users" ] && DATA=$(echo $(cat $f) "{\"data\":{\"password\":\"$(pwgen)\"}}" | jq -s '.[0] * .[1]')
  $CURL/$TYPE -X PUT -H "X-Auth-Token: $AUTH_TOKEN" -d"$DATA"  | jq
done
)
