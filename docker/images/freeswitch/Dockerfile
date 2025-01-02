arg BASE_IMAGE
from ${BASE_IMAGE}

run yum install -y --skip-broken kazoo-freeswitch jq && \
  yum clean all && \
  /sbin/kazoo-freeswitch prepare

copy bin/* /usr/local/bin

cmd /sbin/kazoo-freeswitch start
