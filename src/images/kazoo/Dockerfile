arg BASE_IMAGE
from ${BASE_IMAGE}

arg KZ_UID
run adduser --uid ${KZ_UID} kazoo

run yum install -y kazoo-application* monster-ui* sysvinit-tools jq pwgen bind-utils && \
  yum clean all && \
  /sbin/kazoo-applications prepare

cmd /sbin/kazoo-applications start
