arg BASE_IMAGE
from ${BASE_IMAGE}

run yum install -y --skip-broken kazoo-freeswitch jq bind-utils && \
  yum clean all && \
  /sbin/kazoo-freeswitch prepare

cmd /sbin/kazoo-freeswitch start
