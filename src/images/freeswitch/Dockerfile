arg BASE_IMAGE
from ${BASE_IMAGE}

run yum install -y --skip-broken kazoo-freeswitch jq bind-utils && \
  yum clean all && \
  /sbin/kazoo-freeswitch prepare
run sed -i 's/"freeswitch"/"freeswitch@$${local_ip_v4}"/' /etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml

cmd /sbin/kazoo-freeswitch start
