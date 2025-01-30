arg BASE_IMAGE
from ${BASE_IMAGE}

run yum install -y kazoo-application* monster-ui* sysvinit-tools jq pwgen bind-utils && \
  yum clean all && \
  /sbin/kazoo-applications prepare

copy etc/* /etc/kazoo/core/

cmd /sbin/kazoo-applications start
