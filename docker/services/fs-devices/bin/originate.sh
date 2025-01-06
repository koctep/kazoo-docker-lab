#!/bin/bash

TOTAL_CALLS=$1
MAX_CALLS=$2
CPS=$3
ORIGINATE_CMD=$4

LEGS_CMD="fs_cli -x 'show channels as json'"
LEGS_CMD+="| jq '[ (if .rows then .rows else [] end)[] | select (.direction == \"outbound\") ] | length'"

i=1
while [ $i -le ${TOTAL_CALLS} ]; do
  legs=$(bash -c "$LEGS_CMD")
  [ $legs -gt $MAX_CALLS ] && sleep 1 && continue
  fs_cli -x "${ORIGINATE_CMD}"&
  [ $(( $i % ${CPS} )) -eq 0 ] && sleep 1
  i=$(( $i + 1))
done
