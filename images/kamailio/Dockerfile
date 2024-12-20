arg BASE_IMAGE
from $BASE_IMAGE

run yum install -y kazoo-kamailio && \
  yum clean all && \
  /sbin/kazoo-kamailio prepare

cmd /sbin/kazoo-kamailio foreground
