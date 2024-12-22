arg BASE_IMAGE
from ${BASE_IMAGE}

run yum install -y kazoo-application* monster-ui* sysvinit-tools jq pwgen && \
  yum clean all && \
  /sbin/kazoo-applications prepare

copy etc/config.ini /etc/kazoo/core
copy etc/sys.config /etc/kazoo/core
copy bin/init.sh /usr/local/bin

cmd /sbin/kazoo-applications start
