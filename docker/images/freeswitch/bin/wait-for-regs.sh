#!/bin/sh

regs_total=1
reged=0

while [ $reged -lt $regs_total ]; do
  sleep 1
  out=$(fs_cli -x 'sofia status profile')
  regs_total=$(echo "$out" | grep 'gateways:' | awk '{print $1}')
  reged=$(echo "$out" | grep -c REGED)
  echo "reged $reged / $regs_total"
done
