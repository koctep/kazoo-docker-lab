arg BASE_IMAGE
from $BASE_IMAGE

run yum install -y kazoo-kamailio && \
  yum clean all && \
  /sbin/kazoo-kamailio prepare

copy kazoo-kamailio /sbin
copy local.cfg /etc/kazoo/kamailio

cmd /sbin/kazoo-kamailio foreground
