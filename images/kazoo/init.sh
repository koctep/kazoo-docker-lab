#!/bin/sh

sup crossbar_maintenance create_account kazoo kazoo kazoo kazoo
if [ $? -ne 0 ]; then
  exit 1
fi
sup kazoo_apps_maintenance start ecallmgr
sup kazoo_apps_maintenance start konami
sup ecallmgr_maintenance add_fs_node freeswitch@fs-kz.kz
