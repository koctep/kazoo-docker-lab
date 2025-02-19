#!/bin/sh

SED_CMD='s/"auth-calls" value=".*"/"auth-calls" value="false"/;'
SED_CMD+='s/"apply-inbound-acl" value=".*"/"apply-inbound-acl" value="localnet.auto"/;'
SED_CMD+='s/"apply-proxy-acl" value=".*"/"apply-proxy-acl" value="localnet.auto"/;'

sed -i "$SED_CMD" /etc/kazoo/freeswitch/sip_profiles/sipinterface_1.xml

fs_cli -x 'load mod_sofia'
